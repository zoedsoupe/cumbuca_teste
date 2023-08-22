defmodule Cumbuca.Transactions.Repository do
  @moduledoc "Repository for interact in the Database level for Transactions context"

  use Cumbuca, :repository

  alias Cumbuca.Transactions.Models.Transaction

  @behaviour Cumbuca.Transactions.RepositoryBehaviour

  @impl true
  def fetch_transaction(ident) do
    Repo.fetch_by(Transaction, identifier: ident)
  end

  @impl true
  def list_transactions_by_period(from, to) do
    Repo.all(
      from t in Transaction,
        join: s in assoc(t, :sender),
        join: r in assoc(t, :receiver),
        where: t.processed_at >= ^from,
        where: t.processed_at <= ^to,
        select: %{transaction: t, sender: s, receiver: r}
    )
  end

  @impl true
  def upsert_transaction(transaction \\ %Transaction{}, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.insert_or_update()
  end
end
