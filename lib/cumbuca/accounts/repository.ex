defmodule Cumbuca.Accounts.Repository do
  @moduledoc "Repository to interact with database on the Accounts context"

  use Cumbuca, :repository

  alias Cumbuca.Accounts.Models.BankAccount
  alias Cumbuca.Accounts.Models.User

  @behaviour Cumbuca.Accounts.RepositoryBehaviour

  @spec create_user_account_transaction(map) :: {:ok, map} | {:error, Repo.changeset()}
  def create_user_account_transaction(params) do
    Repo.transaction(fn ->
      with {:ok, user} <- upsert_user(params),
           bank_account_attrs = Map.put(params, :user_id, user.id),
           {:ok, bank_account} <- upsert_bank_account(bank_account_attrs) do
        %{user: user, bank_account: bank_account}
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @impl true
  def fetch_user(id) do
    Repo.fetch_by(User, id: id)
  end

  @impl true
  def fetch_user_by_public_id(public_id) do
    Repo.fetch_by(User, public_id: public_id)
  end

  @impl true
  def upsert_user(user \\ %User{}, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @impl true
  def fetch_bank_account(ident) do
    Repo.fetch_by(BankAccount, identifier: ident)
  end

  @impl true
  def upsert_bank_account(bank_account \\ %BankAccount{}, attrs) do
    bank_account
    |> BankAccount.changeset(attrs)
    |> Repo.insert_or_update()
  end
end
