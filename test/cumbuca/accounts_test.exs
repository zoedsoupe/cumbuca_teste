defmodule Cumbuca.AccountsTest do
  use Cumbuca.DataCase, async: true

  import Cumbuca.AccountsFixtures

  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.UserAccountAdapter

  @moduletag :unit

  describe "retrieve_user_account/1" do
    test "should return :not_found on non exist accounts" do
      assert {:error, :not_found} = Accounts.retrieve_user_account("non-exist")
    end

    test "should return an exist user account" do
      user = user_fixture()
      bank_account = bank_account_fixture(user.id)

      user_account =
        UserAccountAdapter.internal_to_external(%{user: user, bank_account: bank_account})

      assert {:ok, ^user_account} = Accounts.retrieve_user_account(bank_account.identifier)
    end
  end

  describe "register_user_account/1" do
    @invalid_user_params %{cpf: 123, first_name: nil}
    @valid_params %{
      cpf: "32731996102",
      first_name: "Dummy",
      last_name: "User",
      balance: 1000
    }

    test "should return an error changeset on invalid user params" do
      assert {:error, changeset} = Accounts.register_user_account(@invalid_user_params)
      refute changeset.valid?
      assert errors_on(changeset)[:cpf]
      assert errors_on(changeset)[:first_name]
    end

    test "should return an user_account on valid params" do
      assert {:ok, user_account} = Accounts.register_user_account(@valid_params)
      assert user_account.identifier
      assert user_account.owner_cpf == @valid_params.cpf
      assert user_account.owner_first_name == @valid_params.first_name
      assert user_account.owner_last_name == @valid_params.last_name
      assert user_account.balance == Money.to_string(Money.new(@valid_params.balance))
    end
  end
end
