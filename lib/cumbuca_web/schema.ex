defmodule CumbucaWeb.Schema do
  @moduledoc "Main Absinthe GraphQL schema"

  use Absinthe.Schema

  alias CumbucaWeb.Middlewares

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
    field :check_balance, :string do
      middleware(Middlewares.EnsureAuthentication)
      resolve(&CumbucaWeb.Resolvers.Accounts.check_balance/3)
    end

    field :transactions, list_of(:transaction) do
      arg(:from_period, :naive_datetime)
      arg(:to_period, :naive_datetime)

      middleware(Middlewares.EnsureAuthentication)
      resolve(&CumbucaWeb.Resolvers.Transactions.list/2)
    end
  end

  input_object :login_input do
    field :cpf, :string
    field :account_identifier, :string
  end

  input_object :registration_input do
    field :cpf, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, :string
    field :balance, :integer
  end

  object :login_response do
    field :token, :string
  end

  mutation do
    field :register_account, :user_account do
      arg(:input, :registration_input)

      resolve(&CumbucaWeb.Resolvers.Accounts.register_account/2)
    end

    field :login, :login_response do
      arg(:input, :login_input)

      resolve(&CumbucaWeb.Resolvers.Accounts.login/2)
    end
  end

  def middleware(middleware, _field, _object) do
    middleware ++ [Middlewares.ErrorHandler]
  end
end
