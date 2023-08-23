defmodule CumbucaWeb.Schema do
  @moduledoc "Main Absinthe GraphQL schema"

  use Absinthe.Schema

  scalar :naive_datetime, name: "NaiveDateTime" do
    serialize(&NaiveDateTime.to_iso8601/1)
    parse(&parse_naive_date_time/1)
  end

  defp parse_naive_date_time(%Absinthe.Blueprint.Input.String{value: value}) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, date} -> {:ok, date}
      _error -> :error
    end
  end

  defp parse_naive_date_time(%Absinthe.Blueprint.Input.Null{}), do: {:ok, nil}
  defp parse_naive_date_time(_), do: :error

  object :user_account do
    field :balance, :string
    field :owner_cpf, :string
    field :owner_first_name, :string
    field :owner_last_name, :string
    field :identifier, :string
  end

  object :transaction do
    field :amount, :string
    field :processed_at, :string
    field :chargebacked_at, :string
    field :sender, :user_account
    field :receiver, :user_account
  end

  query do
    field :transactions, list_of(:transaction) do
      arg(:from_period, :naive_datetime)
      arg(:to_period, :naive_datetime)

      resolve(&CumbucaWeb.Resolvers.Transactions.list/2)
    end
  end

  input_object :login_input do
    field :cpf, :string
    field :account_identifier, :string
  end

  object :login_response do
    field :token, :string
  end

  mutation do
    field :login, :login_response do
      arg(:input, :login_input)

      resolve(&CumbucaWeb.Resolvers.Accounts.login/2)
    end
  end

  alias CumbucaWeb.Middlewares

  def middleware(middleware, _field, _object) do
    middleware ++ [Middlewares.EnsureAuthentication, Middlewares.ErrorHandler]
  end
end
