defmodule Cumbuca.Repo do
  use Ecto.Repo,
    otp_app: :cumbuca,
    adapter: Ecto.Adapters.Postgres
end

defmodule Cumbuca.Repo.Replica do
  use Ecto.Repo,
    otp_app: :cumbuca,
    adapter: Ecto.Adapters.Postgres,
    read_only: true,
    default_dynamic_repo:
      Application.compile_env!(:cumbuca, [Cumbuca.Repo.Replica, :default_dynamic_repo])
end
