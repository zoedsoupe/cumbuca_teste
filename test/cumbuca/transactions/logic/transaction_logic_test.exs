defmodule Cumbuca.Transactions.TransactionLogicTest do
  use Cumbuca.DataCase, async: true

  import Cumbuca.AccountsFixtures

  alias Cumbuca.Transactions.TransactionLogic

  @moduletag :unit

  describe "validate_transaction/3" do
    setup do
      sender = bank_account_fixture(%{balance: Money.new(100)}, user_fixture().id)

      receiver =
        bank_account_fixture(%{balance: Money.new(100)}, user_fixture(%{cpf: "74057038876"}).id)

      %{sender: sender, receiver: receiver}
    end

    test "should return :invalid_params error on nil values" do
      assert {:error, :invalid_params} == TransactionLogic.validate_transaction(nil, nil, nil)
    end

    test "should return :same_account error on same sender and receiver", %{sender: sender} do
      assert {:error, :same_account} ==
               TransactionLogic.validate_transaction(sender, sender, Money.new(100))
    end

    test "should return :insufficient_funds error when the sender does not have funds", %{
      sender: sender,
      receiver: receiver
    } do
      assert {:error, :insufficient_funds} ==
               TransactionLogic.validate_transaction(sender, receiver, Money.new(999_999_999_999))
    end

    test "should return :ok success on a valid transaction", %{sender: sender, receiver: receiver} do
      assert :ok == TransactionLogic.validate_transaction(sender, receiver, Money.new(100))
    end
  end
end
