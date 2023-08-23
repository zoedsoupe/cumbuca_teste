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
    with {:ok, struct} <- TransactionAdapter.external_to_internal(params),
         {:ok, transaction} <- Repository.upsert_transaction(Map.from_struct(struct)) do
      transaction.identifier
      |> transaction_process_scheduled_message()
      |> Logger.info()
    end
  end

  def transact!(%TransactEvent{} = event) do
    with {:ok, sender} <- Accounts.retrieve_bank_account(event.sender_identifier),
         {:ok, receiver} <- Accounts.retrieve_bank_account(event.receiver_identifier),
         :ok <- maybe_fails_transaction(sender, receiver, event),
         {:ok, :done} <-
           Accounts.transfer_amount_between_accounts(sender, receiver, event.amount),
         {:ok, _transaction} <- set_transaction_processed(event) do
      :ok
    else
      :error ->
        event
        |> transfer_error_message()
        |> Logger.error()

      {:error, :not_found} ->
        event
        |> account_does_not_exists_error_message()
        |> Logger.error()

      {:error, validation_error} ->
        event
        |> transaction_validation_error_message(validation_error)
        |> Logger.error()
    end
  end

  defp maybe_fails_transaction(sender, receiver, event) do
    case TransactionLogic.validate_transaction(sender, receiver, event.amount) do
      {:error, _} = err ->
        set_transaction_failed(event)
        err

      :ok ->
        :ok
    end
  end

  defp set_transaction_failed(%TransactEvent{} = event) do
    with {:ok, transaction} <- Repository.fetch_transaction(event.transaction_identifier) do
      Repository.upsert_transaction(transaction, %{status: :failed})
    end
  end

  defp set_transaction_processed(%TransactEvent{} = event) do
    with {:ok, transaction} <- Repository.fetch_transaction(event.transaction_identifier) do
      Repository.upsert_transaction(transaction, %{
        status: :success,
        processed_at: NaiveDateTime.utc_now()
      })
    end
  end

  defp transaction_validation_error_message(event, error) do
    "[#{__MODULE__}] ==> Transaction #{inspect(event)} failed with: #{error}"
  end

  defp account_does_not_exists_error_message(event) do
    "[#{__MODULE__}] ==> Transaction #{inspect(event)} failed because one of accounts does not exist"
  end

  defp transaction_process_scheduled_message(identifier) do
    "[#{__MODULE__}] ==> Transaction scheduled: #{identifier}"
  end

  defp transfer_error_message(event) do
    "[#{__MODULE__}] ==> Transaction #{inspect(event)} failed transfer between accounts"
  end
end
