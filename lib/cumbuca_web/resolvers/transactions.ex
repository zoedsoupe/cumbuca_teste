defmodule CumbucaWeb.Resolvers.Transactions do
  @moduledoc "Transactions resolvers"

  alias Cumbuca.Transactions

  def list(%{from_period: from, to_period: to}, _resolution) do
    {:ok, Transactions.list_transactions(from, to)}
  end
end
