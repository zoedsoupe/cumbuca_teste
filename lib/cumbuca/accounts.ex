defmodule Cumbuca.Accounts do
  @moduledoc "Context to interact with user accounts"

  alias Cumbuca.Accounts.Repository
  alias Cumbuca.Accounts.UserAccountAdapter
  alias Cumbuca.Repo

  @opaque cpf :: String.t()

  @spec register_user_account(map) ::
          {:ok, UserAccount.t()} | {:error, Repo.changeset()}
  def register_user_account(params) do
    case Repository.create_user_account_transaction(params) do
      {:ok, models} -> {:ok, UserAccountAdapter.internal_to_external(models)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @spec retrieve_user_account(cpf) :: {:ok, UserAccount.t()} | {:error, :not_found}
  def retrieve_user_account(cpf) do
  end
end
