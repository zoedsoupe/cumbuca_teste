defmodule Cumbuca.Accounts.Repository do
  @moduledoc "Repository to interact with database on the Accounts context"

  use Cumbuca, :repository

  alias Cumbuca.Accounts.Models.BankAccount
  alias Cumbuca.Accounts.Models.User

  @behaviour Cumbuca.Accounts.RepositoryBehaviour

  @impl true
  def update_accounts_balance_transaction(sender, receiver, sender_attrs, receiver_attrs) do
    Repo.transaction(fn ->
      with {:ok, _} <- upsert_bank_account(sender, sender_attrs),
           {:ok, _} <- upsert_bank_account(receiver, receiver_attrs) do
        :done
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

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
  def fetch_user_by_cpf_and_public_id(cpf, public_id) do
    query =
      from u in User,
        where: u.public_id == ^public_id,
        where: u.cpf == ^cpf

    if user = Repo.one(query), do: {:ok, user}, else: {:error, :not_found}
  end

  @impl true
  def fetch_user_by_public_id(public_id) do
    query = from u in User, where: u.public_id == ^public_id, select: u, preload: [:bank_account]
    if user = Repo.one(query), do: {:ok, user}, else: {:error, :not_found}
  end

  @impl true
  def upsert_user(user \\ %User{}, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @impl true
  def fetch_bank_account(ident) do
    Repo.fetch(
      from b in BankAccount,
        where: b.identifier == ^ident,
        join: u in assoc(b, :user),
        select: %{user: u, bank_account: b}
    )
  end

  @impl true
  def upsert_bank_account(bank_account \\ %BankAccount{}, attrs) do
    bank_account
    |> BankAccount.changeset(attrs)
    |> Repo.insert_or_update()
  end
end
