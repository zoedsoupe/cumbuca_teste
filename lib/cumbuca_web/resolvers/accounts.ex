defmodule CumbucaWeb.Resolvers.Accounts do
  @moduledoc "Accounts resolvers"

  alias Cumbuca.Accounts

  @token_salt "user authentication"

  def login(%{input: %{cpf: cpf, account_identifier: ident}}, _resolution) do
    case Accounts.retrieve_user_by_cpf_and_identifier(cpf, ident) do
      {:ok, user} ->
        token = Phoenix.Token.sign(CumbucaWeb.Endpoint, @token_salt, user.public_id)
        {:ok, %{token: token}}

      error ->
        error
    end
  end
end
