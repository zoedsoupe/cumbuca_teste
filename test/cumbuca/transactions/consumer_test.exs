defmodule Cumbuca.Transactions.ConsumerTest do
  use Cumbuca.DataCase, async: true

  import Cumbuca.AccountsFixtures
  import Cumbuca.TransactionsFixtures

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

  defp notify_consumer(pid, event) do
    alias Ecto.Adapters.SQL.Sandbox
    Sandbox.allow(Cumbuca.Repo, self(), pid)
    raw_event = Jason.encode!(%{payload: event})
    notification = {:notification, "pid", "ref", "process_transaction", raw_event}
    Process.send(pid, notification, [])
  end

  describe "when receive a notification from postgres with a invalid transaction" do
    test "with sender is the same as receiver", %{
      event: event,
      sender: sender,
      transaction: transaction
    } do
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
    end

    test "with sender with insufficient funds", %{
      event: event,
      sender: sender,
      receiver: receiver,
      transaction: transaction
    } do
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
