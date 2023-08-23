defmodule Cumbuca.Transactions.Schemas.AccountTransaction do
  @moduledoc "Represents an external Bank Account Transaction"

  use Cumbuca, :schema

  alias Cumbuca.Accounts.Schemas.UserAccount

  @type t :: %__MODULE__{
          amount: String.t(),
          processed_at: String.t(),
          sender: UserAccount.t(),
          receiver: UserAccount.t()
        }

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :amount, :string
    field :processed_at, :string
    field :chargebacked_at, :string

    embeds_one :sender, UserAccount
    embeds_one :receiver, UserAccount
  end

  @impl true
  def parse!(params) do
    %AccountTransaction{}
    |> cast(params, [:amount, :processed_at, :chargebacked_at])
    |> put_embed(:sender, params[:sender], required: true)
    |> put_embed(:receiver, params[:receiver], required: true)
    |> apply_action!(:parse)
  end
end
