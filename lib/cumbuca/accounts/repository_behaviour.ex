defmodule Cumbuca.Accounts.RepositoryBehaviour do
  @moduledoc """
  Behaviour to be implemented by the repository module
  """

  alias Cumbuca.Accounts.Models.BankAccount
  alias Cumbuca.Accounts.Models.User
  alias Cumbuca.Repo

  @callback fetch_user(Repo.id()) :: {:ok, User.t()} | {:error, :not_found}
  @callback fetch_user_by_public_id(id) :: {:ok, User.t()} | {:error, :not_found}
            when id: String.t()
  @callback upsert_user(User.t(), map) :: Repo.changeset()

  @callback fetch_bank_account(ident) :: {:ok, BankAccount.t()} | {:error, :not_found}
            when ident: String.t()
  @callback upsert_bank_account(BankAccount.t(), map) ::
              {:ok, BankAccount.t()} | {:error, :not_found}
  @callback update_accounts_balance_transaction(sender, receiver, sender_attrs, receiver_attrs) ::
              :ok | :error
            when sender: BankAccount.t(),
                 receiver: BankAccount.t(),
                 sender_attrs: map,
                 receiver_attrs: map
end
