defmodule CumbucaWeb.Schema do
  @moduledoc "Main Absinthe GraphQL schema"

  use Absinthe.Schema

  alias CumbucaWeb.Middlewares
  alias CumbucaWeb.Resolvers

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
      resolve(&Resolvers.Accounts.check_balance/3)
    end

    field :transactions, list_of(:transaction) do
      arg(:from_period, :naive_datetime)
      arg(:to_period, :naive_datetime)

      middleware(Middlewares.EnsureAuthentication)
      resolve(&Resolvers.Transactions.list/2)
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

  input_object :transact_input do
    field :amount, non_null(:integer)
    field :receiver, non_null(:string)
  end

  object :login_response do
    field :token, :string
  end

  object :transaction_process_response do
    field :identifier, :string
  end

  mutation do
    field :transact, :transaction_process_response do
      arg(:input, non_null(:transact_input))
      middleware(Middlewares.EnsureAuthentication)
      resolve(&Resolvers.Transactions.transact/2)
    end

    field :chargeback_transaction, :transaction_process_response do
      arg(:identifier, non_null(:string))
      middleware(Middlewares.EnsureAuthentication)
      resolve(&Resolvers.Transactions.chargeback_transaction/2)
    end

    field :register_account, :user_account do
      arg(:input, :registration_input)

      resolve(&Resolvers.Accounts.register_account/2)
    end

    field :login, :login_response do
      arg(:input, :login_input)

      resolve(&Resolvers.Accounts.login/2)
    end
  end

  subscription do
    field :transaction_processed, :transaction do
      config(fn _args, _info -> {:ok, topic: "*"} end)
      middleware(Middlewares.EnsureAuthentication)
      resolve(&Resolvers.Transactions.transaction_processed/3)
    end

    field :transaction_chargebacked, :transaction do
      config(fn _args, _info -> {:ok, topic: "*"} end)
      middleware(Middlewares.EnsureAuthentication)
      resolve(&Resolvers.Transactions.transaction_processed/3)
    end
  end

  def middleware(middleware, _field, _object) do
    middleware ++ [Middlewares.ErrorHandler]
  end
end
