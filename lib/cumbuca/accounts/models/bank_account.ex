defmodule Cumbuca.Accounts.Models.BankAccount do
  @moduledoc "Model that defines a user account to be able to do transactions"

  use Cumbuca, :model

  alias Cumbuca.Accounts.Models.User

  @type t :: %BankAccount{
          id: integer,
          balance: integer,
          identifier: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t() | nil,
          user: User.t()
        }

  schema "bank_account" do
    field :balance, :integer, default: 0
    field :identifier, Cumbuca.Ecto.Type.UniqueID, autogenerate: true

    belongs_to :user, User

    timestamps()
  end

  @impl true
  def changeset(%__MODULE__{} = bank_account, attrs) do
    bank_account
    |> cast(attrs, [:balance, :user_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
  end
end
