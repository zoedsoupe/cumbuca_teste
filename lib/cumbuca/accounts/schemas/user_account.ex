defmodule Cumbuca.Accounts.Schemas.UserAccount do
  @moduledoc "Schema that represent user accounts externally"

  use Cumbuca, :schema

  @fields ~w(balance identifier owner_cpf owner_last_name owner_first_name)a

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :balance, :integer
    field :identifier, :string
    field :owner_cpf, :string
    field :owner_first_name, :string
    field :owner_last_name, :string
  end

  @impl true
  def parse!(params) do
    %UserAccount{}
    |> cast(params, @fields)
    |> validate_required(~w(balance identifier owner_cpf owner_first_name)a)
    |> apply_action!(:parse)
  end
end
