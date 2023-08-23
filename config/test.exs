import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
repo_opts = [
  username: "zoedsoupe",
  hostname: "localhost",
  database: "cumbuca_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
]

config :cumbuca, Cumbuca.Repo, repo_opts
config :cumbuca, Cumbuca.Repo.Replica, [{:default_dynamic_repo, Cumbuca.Repo} | repo_opts]

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cumbuca, CumbucaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KuZnF6x+gjm0tHQcfk8TNAqsA0OOxiXfScsyPzegTqzGDu+BDdW88hAc+yTWtSc0",
  server: false

# Print only warnings and errors during test
config :logger, level: :none

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
