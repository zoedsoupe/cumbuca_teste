defmodule Cumbuca.Transactions.TransactEvent do
  @moduledoc "Event that represents a Transaction to be processed"

  use Cumbuca, :schema

  @type t :: %TransactEvent{
          amount: Money.t(),
          sender_identifier: String.t(),
          receiver_identifier: String.t()
        }

  @primary_key false
  embedded_schema do
    field :amount, Money.Ecto.Map.Type
    field :sender_identifier, :string
    field :receiver_identifier, :string
    field :transaction_identifier, :string
  end

  @impl true
  def parse!(params) do
    %TransactEvent{}
    |> cast(params, [
      :amount,
      :sender_identifier,
      :receiver_identifier,
      :transaction_identifier
    ])
    |> validate_required([
      :sender_identifier,
      :receiver_identifier,
      :transaction_identifier
    ])
    |> apply_action!(:parse)
  end
end
