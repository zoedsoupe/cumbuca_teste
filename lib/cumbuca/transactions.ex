defmodule Cumbuca.Transactions do
  @moduledoc "Context that manage Bank Accounts Transactions"

  alias Cumbuca.Accounts
  alias Cumbuca.Transactions.Repository
  alias Cumbuca.Transactions.TransactionAdapter
  alias Cumbuca.Transactions.TransactEvent
  alias Cumbuca.Transactions.TransactionLogic

  require Logger

  @opaque transact_params :: %{sender: String.t(), receiver: String.t(), amount: integer}

  @spec schedule_new_transaction(transact_params) :: :ok
  def schedule_new_transaction(params) do
    with {:ok, transaction} <-
           params
           |> TransactionAdapter.external_to_new_internal()
           |> Repository.upsert_transaction() do
      Logger.info("[#{__MODULE__}] ==> Transaction scheduled: #{transaction.identifier}")
    end
  end

  def transact!(%TransactEvent{} = event) do
    with {:ok, _transaction} <- update_transsaction_status(event.transaction_identifier),
         {:ok, sender} <- Accounts.retrieve_bank_account(event.sender_identifier),
         {:ok, receiver} <- Accounts.retrieve_bank_account(event.receiver_identifier),
         :ok <- TransactionLogic.validate_transaction(sender, receiver, event.amount) do
      {:ok, :done} = Accounts.transfer_amount_between_accounts(sender, receiver, event.amount)
      :ok
    else
      {:error, :not_found} ->
        Logger.error(
          "[#{__MODULE__}] ==> Transaction #{inspect(event)} failed because one of accounts does not exist"
        )

      {:error, validation_error} ->
        Logger.error(
          "[#{__MODULE__}] ==> Transaction #{inspect(event)} failed with: #{validation_error}"
        )
    end
  end

  defp update_transsaction_status(identifer) do
    with {:ok, transaction} <- Repository.fetch_transaction(identifer) do
      Repository.upsert_transaction(transaction, %{processed_at: NaiveDateTime.utc_now()})
    end
  end
end
