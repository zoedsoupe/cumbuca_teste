defmodule Cumbuca.Transactions.Consumer do
  @moduledoc "Consumes Transaction events and process them"

  use GenServer

  alias Cumbuca.Transactions.TransactEventAdapter

  require Logger

  @events Application.compile_env!(:cumbuca, :postgres_events)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_dummy) do
    for event_name <- @events do
      Cumbuca.Repo.listen(event_name)
    end

    {:ok, []}
  end

  @impl true
  def handle_cast({:process_transaction, event}, state) do
    Cumbuca.Transactions.transact!(event)
    {:noreply, state}
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "process_transaction", raw}, state) do
    payload = Jason.decode!(raw)
    event = TransactEventAdapter.external_to_internal(payload["payload"])
    GenServer.cast(__MODULE__, {:process_transaction, event})
    {:noreply, state}
  end
end
