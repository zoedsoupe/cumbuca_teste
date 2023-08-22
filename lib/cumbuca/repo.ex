defmodule Cumbuca.Repo do
  use Ecto.Repo,
    otp_app: :cumbuca,
    adapter: Ecto.Adapters.Postgres

  @opaque id :: integer
  @opaque changeset :: Ecto.Changeset.t()

  @spec fetch_by(module, keyword) :: {:ok, struct} | {:error, :not_found}
  def fetch_by(source, params) do
    if result = get_by(source, params) do
      {:ok, result}
    else
      {:error, :not_found}
    end
  end
end
