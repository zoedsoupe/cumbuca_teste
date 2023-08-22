defmodule Cumbuca.AccountsFixtures do
  alias Cumbuca.Accounts

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      cpf: "90318175037",
      first_name: "dummy",
      last_name: "last"
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.Repository.upsert_user()

    user
  end
end
