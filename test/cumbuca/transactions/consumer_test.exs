defmodule Cumbuca.Transactions.ConsumerTest do
  use Cumbuca.DataCase, async: false

  import Cumbuca.AccountsFixtures
  import Cumbuca.TransactionsFixtures
  import ExUnit.CaptureLog

  alias Cumbuca.Accounts.Models.BankAccount
  alias Cumbuca.Repo
  alias Cumbuca.Transactions.Consumer
  alias Cumbuca.Transactions.Models.Transaction
  alias Cumbuca.Transactions.TransactEvent

  @moduletag :integration

  @default_balance Money.new(100)

  setup do
    sender = bank_account_fixture(%{balance: @default_balance}, user_fixture().id)
    receiver = bank_account_fixture(user_fixture().id)

    transaction =
      transaction_fixture(sender.identifier, receiver.identifier, %{amount: @default_balance})

    event = %TransactEvent{
      transaction_identifier: transaction.identifier,
      sender_identifier: sender.identifier,
      receiver_identifier: receiver.identifier
    }

    %{event: event, transaction: transaction, sender: sender, receiver: receiver}
  end

  defp sandbox_allow_pid(pid) do
    alias Ecto.Adapters.SQL.Sandbox
    Sandbox.allow(Cumbuca.Repo, self(), pid)
  end

  defp notify_consumer(pid, event) do
    sandbox_allow_pid(pid)
    raw_event = Jason.encode!(%{payload: event})
    notification = {:notification, "pid", "ref", "process_transaction", raw_event}
    Process.send(pid, notification, [])
  end

  describe "when receive message to chargeback a valid transaction" do
    setup ctx do
      success_transaction =
        transaction_fixture(ctx.sender.identifier, ctx.receiver.identifier, %{
          amount: @default_balance,
          processed_at: ~N[2023-08-23 16:17:18.647539],
          status: :success
        })

      Map.put(ctx, :success_transaction, success_transaction)
    end

    test "should cast the message and process chargeback", %{
      sender: sender,
      receiver: receiver,
      success_transaction: transaction
    } do
      pid = start_supervised!(Consumer, [])
      sandbox_allow_pid(pid)

      assert :ok = Consumer.chargeback_transaction(transaction.identifier)
      assert :sys.get_state(pid) == :processing

      # sender should have the balance updated
      old_balance = sender.balance
      assert %BankAccount{balance: balance} = Repo.reload(sender)
      assert balance == Money.add(old_balance, transaction.amount)

      # receiver should have the balance updated
      old_balance = receiver.balance
      assert %BankAccount{balance: balance} = Repo.reload(receiver)
      assert balance == Money.subtract(old_balance, transaction.amount)

      # transaction should be processed
      assert transaction = Repo.get_by!(Transaction, identifier: transaction.identifier)
      assert transaction.processed_at
      assert transaction.chargebacked_at
      assert transaction.status == :success

      # try to chargeback again will log an error
      assert capture_log([level: :info], fn ->
               assert :ok = Consumer.chargeback_transaction(transaction.identifier)

               # sender SHOUDN't have the balance updated
               sender = Repo.reload(sender)
               old_balance = sender.balance
               assert %BankAccount{balance: balance} = sender
               assert balance == old_balance

               # receiver SHOULDN't have the balance updated
               receiver = Repo.reload(receiver)
               old_balance = receiver.balance
               assert %BankAccount{balance: balance} = receiver
               assert balance == old_balance

               # Transaction should be untouched
               chargebacked_at = transaction.chargebacked_at
               assert %Transaction{chargebacked_at: ^chargebacked_at} = Repo.reload(transaction)
             end) =~ "#{transaction.identifier} was already chargebacked"
    end
  end

  describe "when receive a notification from postgres with a invalid transaction" do
    test "with sender is the same as receiver", %{
      event: event,
      sender: sender,
      transaction: transaction
    } do
      assert capture_log(fn ->
               pid = start_supervised!(Consumer, [])

               invalid_event =
                 event
                 |> Map.put(:amount, @default_balance)
                 |> Map.put(:receiver_identifier, sender.identifier)

               assert :ok = notify_consumer(pid, invalid_event)

               assert :sys.get_state(pid) == :processing

               # sender SHOULDN'T have the balance updated
               old_balance = sender.balance
               assert %BankAccount{balance: balance} = Repo.reload(sender)
               assert balance == old_balance

               # transaction should be updated to FAILED
               assert %Transaction{processed_at: nil, status: :failed} =
                        Repo.get_by!(Transaction, identifier: transaction.identifier)
             end) =~ "same_account"
    end

    test "with sender with insufficient funds", %{
      event: event,
      sender: sender,
      receiver: receiver,
      transaction: transaction
    } do
      assert capture_log(fn ->
               pid = start_supervised!(Consumer, [])
               invalid_event = Map.put(event, :amount, Money.add(@default_balance, Money.new(1)))
               assert :ok = notify_consumer(pid, invalid_event)

               assert :sys.get_state(pid) == :processing

               # sender SHOULDN'T have the balance updated
               old_balance = sender.balance
               assert %BankAccount{balance: balance} = Repo.reload(sender)
               assert balance == old_balance

               # receiver SHOULDN'T have the balance updated
               old_balance = receiver.balance
               assert %BankAccount{balance: balance} = Repo.reload(receiver)
               assert balance == old_balance

               # transaction should be updated to FAILED
               assert %Transaction{processed_at: nil, status: :failed} =
                        Repo.get_by!(Transaction, identifier: transaction.identifier)
             end) =~ "insufficient_funds"
    end
  end

  describe "when receive a notification from postgres with a valid transaction" do
    test "should receive a cast message to process the transaction", %{
      event: event,
      transaction: transaction,
      sender: sender,
      receiver: receiver
    } do
      pid = start_supervised!(Consumer, [])
      valid_event = Map.put(event, :amount, @default_balance)
      assert :ok = notify_consumer(pid, valid_event)

      assert :sys.get_state(pid) == :processing

      # sender should have the balance updated
      old_balance = sender.balance
      assert %BankAccount{balance: balance} = Repo.reload(sender)
      assert balance == Money.subtract(old_balance, transaction.amount)

      # receiver should have the balance updated
      old_balance = receiver.balance
      assert %BankAccount{balance: balance} = Repo.reload(receiver)
      assert balance == Money.add(old_balance, transaction.amount)

      # transaction should be processed
      assert transaction = Repo.get_by!(Transaction, identifier: transaction.identifier)
      assert transaction.processed_at
      assert transaction.status == :success
    end
  end
end
