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

    embeds_one :sender, UserAccount
    embeds_one :receiver, UserAccount
  end

  @impl true
  def parse!(params) do
    %AccountTransaction{}
    |> cast(params, [:amount, :processed_at])
    |> cast_assoc(:sender, required: true, with: &cast_user_account/2)
    |> cast_assoc(:sender, required: true, with: &cast_user_account/2)
    |> apply_action!(:parse)
  end

  defp cast_user_account(_struct, params) do
    UserAccount.parse!(params)
  end
end
