defmodule Cumbuca.Transactions.RepositoryBehaviour do
  @moduledoc "Behaviour for Transaction Repositories"

  alias Cumbuca.Repo
  alias Cumbuca.Transactions.Models.Transaction

  @callback fetch_transaction(ident) :: {:ok, Transaction.t()} | {:error, :not_found}
            when ident: String.t()
  @callback list_transactions_by_period(from, to) :: list(Transaction.t())
            when from: NaiveDateTime.t(),
                 to: NaiveDateTime.t()
  @callback upsert_transaction(Transaction.t(), map) ::
              {:ok, Transaction.t()} | {:error, Repo.changeset()}
end
