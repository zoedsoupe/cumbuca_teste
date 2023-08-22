import Config

config :money,
  default_currency: :BRL

config :cumbuca,
  ecto_repos: [Cumbuca.Repo]

# Configures the endpoint
config :cumbuca, CumbucaWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: CumbucaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Cumbuca.PubSub,
  live_view: [signing_salt: "vzaaTz/z"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
