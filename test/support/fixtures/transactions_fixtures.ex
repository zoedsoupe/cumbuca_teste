defmodule Cumbuca.TransactionsFixtures do
  @moduledoc "Fixtures for Transaction context"

  alias Cumbuca.Transactions

  def transaction_fixture(sender_id, receiver_id, attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Map.put(:sender_id, sender_id)
      |> Map.put(:receiver_id, receiver_id)
      |> Transactions.Repository.upsert_transaction()

    transaction
  end
end
