defmodule Cumbuca.Transactions.Consumer do
  @moduledoc "Consumes Transaction events and process them"

  use GenServer

  alias Cumbuca.Transactions
  alias Cumbuca.Transactions.TransactEventAdapter

  require Logger

  @events Application.compile_env!(:cumbuca, :postgres_events)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec chargeback_transaction(String.t()) :: :ok
  def chargeback_transaction(identifier) do
    GenServer.cast(__MODULE__, {:chargeback_transaction, %{transaction_identifier: identifier}})
  end

  @impl true
  def init(_dummy) do
    for event_name <- @events do
      Cumbuca.Repo.listen(event_name)
    end

    {:ok, []}
  end

  @impl true
  def handle_cast({:chargeback_transaction, %{transaction_identifier: identifier}}, _state) do
    case Transactions.fetch_transaction(identifier) do
      {:ok, transaction} -> Transactions.chargeback!(transaction)
      _ -> Transactions.transaction_does_not_exist_log(identifier)
    end

    {:noreply, :processing}
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "process_transaction", raw}, _) do
    payload = Jason.decode!(raw)
    event = TransactEventAdapter.external_to_internal(payload["payload"])
    Cumbuca.Transactions.transact!(event)
    {:noreply, :processing}
  end
end
