defmodule Cumbuca.Transactions.TransactEventAdapter do
  @moduledoc "Adapter to internalize the Transaction model"

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
end
