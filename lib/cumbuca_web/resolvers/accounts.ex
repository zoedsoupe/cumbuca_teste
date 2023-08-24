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

  def register_account(%{input: input}, _resolution) do
    Accounts.register_user_account(input)
  end

  def check_balance(_args, _resolution, %{context: %{current_user: user}}) do
    with {:ok, account} <- Accounts.retrieve_user_account(user.bank_account.identifier) do
      {:ok, account.balance}
    end
  end
end
