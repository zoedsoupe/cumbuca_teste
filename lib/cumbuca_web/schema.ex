defmodule CumbucaWeb.Schema do
  @moduledoc "Main Absinthe GraphQL schema"

  use Absinthe.Schema

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
