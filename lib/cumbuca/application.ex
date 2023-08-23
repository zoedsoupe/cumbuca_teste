defmodule Cumbuca.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        CumbucaWeb.Telemetry,
        Cumbuca.Repo,
        Cumbuca.Repo.Replica,
        {Phoenix.PubSub, name: Cumbuca.PubSub},
        CumbucaWeb.Endpoint
      ] ++ if config_env() == :test, do: [], else: [Cumbuca.Transactions.Consumer]

    opts = [strategy: :one_for_one, name: Cumbuca.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CumbucaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp config_env do
    Application.fetch_env!(:cumbuca, :config_env)
  end
end
