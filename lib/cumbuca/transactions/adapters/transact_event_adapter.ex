defmodule Cumbuca.Transactions.TransactEventAdapter do
  @moduledoc "Adapter to internalize the Transaction model"

  alias Cumbuca.Transactions.Models.Transaction
  alias Cumbuca.Transactions.TransactEvent

  @spec external_to_internal(map) :: TransactEvent.t()
  def external_to_internal(params) do
    TransactEvent.parse!(%{
      sender_identifier: params["sender_id"],
      receiver_identifier: params["receiver_id"],
      amount: params["amount"],
      transaction_identifier: params["identifier"]
    })
  end

  @spec internal_to_event(Transaction.t()) :: TransactEvent.t()
  def internal_to_event(%Transaction{} = transaction) do
    TransactEvent.parse!(%{
      sender_identifier: transaction.sender_id,
      receiver_identifier: transaction.receiver_id,
      amount: transaction.amount,
      transaction_identifier: transaction.identifier
    })
  end
end
