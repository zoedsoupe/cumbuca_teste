defmodule Cumbuca.Transactions.Poller do
  @moduledoc "Poller to handle transaction events"

  use GenServer

  alias Cumbuca.Transactions
  alias Cumbuca.Transactions.Models.Transaction
  alias Cumbuca.Transactions.TransactEvent

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Phoenix.PubSub.subscribe(Cumbuca.PubSub, "transaction:processed")
    Phoenix.PubSub.subscribe(Cumbuca.PubSub, "transaction:chargebacked")
    {:ok, :does_not_matter}
  end

  @impl true
  def handle_info(%TransactEvent{} = event, state) do
    with {:ok, transaction} <- Transactions.retrieve_transaction(event.transaction_identifier) do
      Absinthe.Subscription.publish(CumbucaWeb.Endpoint, transaction, transaction_processed: "*")
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(%Transaction{} = transaction, state) do
    with {:ok, account_transaction} <- Transactions.retrieve_transaction(transaction.identifier) do
      Absinthe.Subscription.publish(CumbucaWeb.Endpoint, account_transaction,
        transaction_chargebacked: "*"
      )
    end

    {:noreply, state}
  end
end
