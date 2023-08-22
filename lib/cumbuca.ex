defmodule Cumbuca do
  @moduledoc false

  defmodule ModelBehaviour do
    @moduledoc "Simple module to define models behaviour"
    @callback changeset(struct, map) :: Cumbuca.Repo.changeset()
  end

  defmodule SchemaBehaviour do
    @moduledoc "Simple module to define schemas behaviour"
    @callback parse!(map) :: struct
  end

  def model do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias __MODULE__

      @behaviour Cumbuca.ModelBehaviour
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias __MODULE__

      @behaviour Cumbuca.SchemaBehaviour
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
