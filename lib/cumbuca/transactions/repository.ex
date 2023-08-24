defmodule Cumbuca.Transactions.Repository do
  @moduledoc "Repository for interact in the Database level for Transactions context"

  use Cumbuca, :repository

  alias Cumbuca.Transactions.Models.Transaction

  @behaviour Cumbuca.Transactions.RepositoryBehaviour

  @impl true
  def fetch_transaction(ident) do
    query =
      from t in Transaction,
        join: s in assoc(t, :sender),
        join: r in assoc(t, :receiver),
        join: su in assoc(s, :user),
        join: ru in assoc(r, :user),
        where: t.identifier == ^ident,
        select: %{
          transaction: t,
          sender: %{user: su, bank_account: s},
          receiver: %{user: ru, bank_account: r}
        }

    if transaction = Repo.one(query) do
      {:ok, transaction}
    else
      {:error, :not_found}
    end
  end

  @impl true
  def list_transactions_by_period(from, to) do
    Repo.all(
      from t in Transaction,
        join: s in assoc(t, :sender),
        join: r in assoc(t, :receiver),
        join: su in assoc(s, :user),
        join: ru in assoc(r, :user),
        where: t.processed_at >= ^from,
        where: t.processed_at <= ^to,
        select: %{
          transaction: t,
          sender: %{user: su, bank_account: s},
          receiver: %{user: ru, bank_account: r}
        }
    )
  end

  @impl true
  def upsert_transaction(transaction \\ %Transaction{}, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.insert_or_update()
  end
end
