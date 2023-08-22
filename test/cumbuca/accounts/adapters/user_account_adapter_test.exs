defmodule Cumbuca.Accounts.UserAccountAdapterTest do
  use Cumbuca.DataCase, async: true

  import Cumbuca.AccountsFixtures

  alias Cumbuca.Accounts.Schemas.UserAccount
  alias Cumbuca.Accounts.UserAccountAdapter

  describe "internal_to_external/1" do
    setup do
      user = user_fixture()
      bank_account = bank_account_fixture(user.id)

      %{user: user, bank_account: bank_account}
    end

    test "should raise on invalid input" do
      assert_raise FunctionClauseError, fn ->
        UserAccountAdapter.internal_to_external(%{})
      end
    end

    test "should return a valid user account on valid params", params do
      assert %UserAccount{} = account = UserAccountAdapter.internal_to_external(params)
      assert account.identifier == params.bank_account.identifier
      assert account.owner_cpf == params.user.cpf
      assert account.owner_first_name == params.user.first_name
      assert account.owner_last_name == params.user.last_name
      assert account.balance == Money.to_string(params.bank_account.balance)
    end
  end
end
