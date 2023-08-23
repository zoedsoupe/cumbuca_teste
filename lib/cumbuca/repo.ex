defmodule Cumbuca.Repo do
  use Ecto.Repo,
    otp_app: :cumbuca,
    adapter: Ecto.Adapters.Postgres

  @opaque id :: integer
  @opaque query :: Ecto.Queryable.t()
  @opaque changeset :: Ecto.Changeset.t()

  @spec fetch_by(module, keyword) :: {:ok, struct} | {:error, :not_found}
  def fetch_by(source, params) do
    if result = get_by(source, params) do
      {:ok, result}
    else
      {:error, :not_found}
    end
  end

  @spec fetch(query) :: {:ok, struct} | {:error, :not_found}
  def fetch(query) do
    case one(query) do
      nil -> {:error, :not_found}
      result -> {:ok, result}
    end
  end

  def listen(event_name) do
    with {:ok, pid} <- Postgrex.Notifications.start_link(__MODULE__.config()),
         {:ok, ref} <- Postgrex.Notifications.listen(pid, event_name) do
      {:ok, pid, ref}
    end
  end
end

defmodule Cumbuca.Repo.Replica do
  use Ecto.Repo,
    otp_app: :cumbuca,
    adapter: Ecto.Adapters.Postgres,
    read_only: true,
    default_dynamic_repo:
      Application.compile_env!(:cumbuca, [Cumbuca.Repo.Replica, :default_dynamic_repo])
end
