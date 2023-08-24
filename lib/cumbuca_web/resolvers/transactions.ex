defmodule CumbucaWeb.Resolvers.Transactions do
  @moduledoc "Transactions resolvers"

  alias Cumbuca.Transactions

  def list(%{from_period: from, to_period: to}, _resolution) do
    {:ok, Transactions.list_transactions(from, to)}
  end

  def chargeback_transaction(%{identifier: identifier}, _resolution) do
    Transactions.schedule_transaction_chargeback(identifier)
    {:ok, %{identifier: identifier}}
  end

  def transact(%{input: input}, %{context: %{current_user: user}}) do
    {:ok, identifier} =
      input
      |> Map.put(:sender, user.bank_account.identifier)
      |> Transactions.schedule_new_transaction()

    {:ok, %{identifier: identifier}}
  end

  def transaction_processed(transaction, _, _resolution) do
    {:ok, transaction}
  end
end
