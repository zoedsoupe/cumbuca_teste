defmodule Cumbuca.Transactions.Models.TransactionTest do
  use Cumbuca.DataCase, async: true

  import Cumbuca.AccountsFixtures
  import Cumbuca.TransactionsFixtures

  alias Cumbuca.Transactions.Models.Transaction

  @moduletag :unit

  describe "changeset/2" do
    @invalid_params %{
      amount: nil,
      sender_id: nil,
      receiver_id: nil
    }
    @missing_required_parms %{amount: 100}

    setup do
      sender = bank_account_fixture(user_fixture().id)
      receiver = bank_account_fixture(user_fixture().id)

      valid_transaction =
        transaction_fixture(sender.identifier, receiver.identifier, %{amount: Money.new(100)})

      valid_params = %{
        amount: Money.new(100),
        sender_id: sender.identifier,
        receiver_id: receiver.identifier,
        processed_at: ~N[2023-08-23 11:17:10.328637]
      }

      %{valid_params: valid_params, valid_transaction: valid_transaction}
    end

    test "should return an error changeset on invalid params" do
      changeset = Transaction.changeset(%Transaction{}, @invalid_params)

      refute changeset.valid?
      assert changeset.errors[:amount]
      assert changeset.errors[:sender_id]
      assert changeset.errors[:receiver_id]
    end

    test "should return an error changset on missing required params" do
      changeset = Transaction.changeset(%Transaction{}, @missing_required_parms)

      refute changeset.valid?
      assert changeset.errors[:sender_id]
      assert changeset.errors[:receiver_id]
    end

    test "should return a valid changeset on valid params", %{valid_params: params} do
      changeset = Transaction.changeset(%Transaction{}, params)

      assert changeset.valid?
      refute changeset.errors[:amount]
      refute changeset.errors[:sender_id]
      refute changeset.errors[:receiver_id]
    end

    test "should return a valid changeset with new values on new changes", %{
      valid_transaction: transaction,
      valid_params: params
    } do
      changeset = Transaction.changeset(transaction, params)

      assert changeset.valid?
      assert changeset.changes[:processed_at]
      refute changeset.errors[:processed_at]
      refute changeset.errors[:amount]
      refute changeset.errors[:sender_id]
      refute changeset.errors[:receiver_id]
    end
  end
end
