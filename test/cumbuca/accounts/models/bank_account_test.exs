defmodule Cumbuca.Accounts.Models.BankAccountTest do
  use Cumbuca.DataCase, async: true

  import Cumbuca.AccountsFixtures

  alias Cumbuca.Accounts.Models.BankAccount

  @moduletag :unit

  describe "changeset/2" do
    @invalid_params %{user_id: nil, balance: "1123"}
    @missing_required_params %{balance: Money.new(123)}

    setup do
      user = user_fixture()
      valid_bank_account = %BankAccount{balance: Money.new(456), user_id: user.id}
      valid_params = %{user_id: user.id, balance: Money.new(123)}

      %{user: user, valid_bank_account: valid_bank_account, valid_params: valid_params}
    end

    test "should return an error changeset on invalid params" do
      changeset = BankAccount.changeset(%BankAccount{}, @invalid_params)

      assert %Ecto.Changeset{valid?: false} = changeset
      assert errors_on(changeset)[:balance]
      assert errors_on(changeset)[:user_id]
    end

    test "should return an error changset on missing required params" do
      changeset = BankAccount.changeset(%BankAccount{}, @missing_required_params)

      assert %Ecto.Changeset{valid?: false} = changeset
      assert errors_on(changeset)[:user_id]
    end

    test "should return a valid changeset on valid params", %{valid_params: params} do
      changeset = BankAccount.changeset(%BankAccount{}, params)

      assert %Ecto.Changeset{valid?: true} = changeset
      refute errors_on(changeset)[:balance]
      refute errors_on(changeset)[:user_id]
    end

    test "should return a valid changeset with new values on new chnages", %{
      valid_bank_account: bank_account,
      valid_params: params
    } do
      changeset = BankAccount.changeset(bank_account, params)

      assert %Ecto.Changeset{valid?: true} = changeset
      refute errors_on(changeset)[:balance]
      refute errors_on(changeset)[:user_id]
    end
  end
end
