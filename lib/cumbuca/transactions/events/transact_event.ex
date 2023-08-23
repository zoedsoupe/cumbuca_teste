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

  defimpl Jason.Encoder, for: __MODULE__ do
    @impl true
    def encode(%TransactEvent{} = event, opts) do
      Jason.Encode.map(encode_map(event), opts)
    end

    defp encode_map(%TransactEvent{} = event) do
      %{
        "amount" => %{"currency" => event.amount.currency, "amount" => event.amount.amount},
        "sender_id" => event.sender_identifier,
        "receiver_id" => event.receiver_identifier,
        "identifier" => event.transaction_identifier
      }
    end
  end
end
