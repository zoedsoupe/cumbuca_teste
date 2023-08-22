defmodule Cumbuca.Ecto.Type.UniqueID do
  @moduledoc """
  Implements a unique ID for entities that need
  to be exposed via web or need an unique internal identifier.

  On you `:ecto` schema, uses

      schema do
        # ...
        field :public_id, Cumbuca.Ecto.Type.UniqueID, autogenerate: true
      end
  """

  use Ecto.Type

  @impl true
  def type, do: :string

  @impl true
  def cast(nano_id), do: {:ok, nano_id}

  @impl true
  def dump(nano_id), do: {:ok, nano_id}

  @impl true
  def load(nano_id), do: {:ok, nano_id}

  @impl true
  def autogenerate, do: Nanoid.generate()
end
