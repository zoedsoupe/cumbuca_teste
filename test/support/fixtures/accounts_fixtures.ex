defmodule Cumbuca.AccountsFixtures do
  @moduledoc "Fixture for models from Accounts context"

  alias Cumbuca.Accounts

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      cpf: "90318175037",
      first_name: "dummy",
      last_name: "last"
    })
  end

  def bank_account_fixture(attrs \\ %{}, user_id) do
    {:ok, bank_account} =
      attrs
      |> Map.put(:user_id, user_id)
      |> Accounts.Repository.upsert_bank_account()

    bank_account
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.Repository.upsert_user()

    user
  end
end
