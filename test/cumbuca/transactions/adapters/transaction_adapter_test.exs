defmodule Cumbuca.Transactions.TransactionAdapterTest do
  use Cumbuca.DataCase, async: true

  import Cumbuca.AccountsFixtures
  import Cumbuca.TransactionsFixtures

  alias Cumbuca.Transactions.TransactionAdapter
  alias Cumbuca.Transactions.Schemas.AccountTransaction

  @moduletag :unit

  describe "internal_to_external/1" do
    test "should raise on invalid params" do
      assert_raise FunctionClauseError, fn ->
        TransactionAdapter.internal_to_external(%{})
      end
    end

    test "should return an AccountTransaction on valid params" do
      sender_user = user_fixture()
      sender = bank_account_fixture(sender_user.id)
      receiver_user = user_fixture()
      receiver = bank_account_fixture(receiver_user.id)

      transaction =
        transaction_fixture(sender.identifier, receiver.identifier, %{
          amount: Money.new(100),
          processed_at: ~N[2023-08-23 11:17:10.328637]
        })

      params = %{
        transaction: transaction,
        sender: %{user: sender_user, bank_account: sender},
        receiver: %{user: receiver_user, bank_account: receiver}
      }

      account_transaction = TransactionAdapter.internal_to_external(params)

      assert %AccountTransaction{} = account_transaction
      assert account_transaction.sender.identifier == params.sender.bank_account.identifier
      assert account_transaction.receiver.identifier == params.receiver.bank_account.identifier
      assert account_transaction.amount == Money.to_string(params.transaction.amount)

      assert account_transaction.processed_at ==
               NaiveDateTime.to_iso8601(params.transaction.processed_at)
    end
  end

  describe "external_to_internal/1" do
    test "should raise on nil amount" do
      assert_raise FunctionClauseError, fn ->
        TransactionAdapter.external_to_internal(%{
          sender: "sender_id",
          receiver: "receiver_id",
          amount: nil
        })
      end
    end

    test "should return a Transaction struct on valid params" do
      amount = Money.new(100)

      assert {:ok, transaction} =
               TransactionAdapter.external_to_internal(%{
                 sender: "sender_id",
                 receiver: "receiver_id",
                 amount: 100
               })

      assert transaction.sender_id == "sender_id"
      assert transaction.receiver_id == "receiver_id"
      assert transaction.amount == amount
      refute transaction.processed_at
    end
  end
end
