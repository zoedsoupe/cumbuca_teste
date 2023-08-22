defmodule Cumbuca do
  @moduledoc false

  def model do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias __MODULE__

      @opaque changeset :: Ecto.Changeset.t()
      @callback changeset(__MODULE__.t(), map) :: changeset
      @behaviour __MODULE__
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias __MODULE__

      @callback parse!(map) :: __MODULE__.t()
      @behaviour __MODULE__
    end
  end

  def repository do
    quote do
      import Ecto.Query
      alias Cumbuca.Repo
      alias Cumbuca.Repo.Replica

      def delete(entity), do: Repo.delete(entity)
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
