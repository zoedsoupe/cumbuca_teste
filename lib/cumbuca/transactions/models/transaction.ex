defmodule Cumbuca.Transactions.Models.Transaction do
  @moduledoc "Represents a Bank Account Transaction"

  use Cumbuca, :model

  alias Cumbuca.Accounts.Models.BankAccount

  @type t :: %__MODULE__{
          id: integer(),
          status: :pending | :failed | :success,
          amount: Money.t(),
          identifier: String.t(),
          processed_at: NaiveDateTime.t(),
          sender: BankAccount.t(),
          receiver: BankAccount.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "transaction" do
    field :amount, Money.Ecto.Map.Type
    field :processed_at, :naive_datetime
    field :identifier, Cumbuca.Ecto.Type.UniqueID, autogenerate: true
    field :status, Ecto.Enum, values: ~w[pending failed success]a, default: :pending

    belongs_to :sender, BankAccount, references: :identifier, type: :string
    belongs_to :receiver, BankAccount, references: :identifier, type: :string

    timestamps()
  end

  @impl true
  def changeset(%Transaction{} = transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :processed_at, :sender_id, :receiver_id, :identifier, :status])
    |> validate_required([:amount, :sender_id, :receiver_id])
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:receiver_id)
  end
end
