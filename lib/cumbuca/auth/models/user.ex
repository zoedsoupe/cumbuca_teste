defmodule Cumbuca.Auth.Models.User do
  @moduledoc """
  The main entity, that holds an Account and do transactions.
  """

  use Cumbuca, :model

  @type t :: %User{
          id: integer,
          cpf: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          public_id: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t() | nil
        }

  @required_fields ~w(cpf first_name)a

  schema "user" do
    field :cpf, :string
    field :first_name, :string
    field :last_name, :string
    field :public_id, Cumbuca.Ecto.Type.UniqueID, autogenerate: true

    timestamps()
  end

  @impl true
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:last_name | @required_fields])
    |> Brcpfcnpj.Changeset.validate_cpf(:cpf)
    |> validate_required(@required_fields)
  end
end
