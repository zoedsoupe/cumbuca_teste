import Config

repo_opts = [
  username: "zoedsoupe",
  hostname: "localhost",
  database: "cumbuca_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
]

# Configure your database
config :cumbuca, Cumbuca.Repo, repo_opts
config :cumbuca, Cumbuca.Repo.Replica, [{:default_dynamic_repo, Cumbuca.Repo.Replica} | repo_opts]

config :cumbuca, CumbucaWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "ZyKzjvUQCCNV1dh32lqUlAgD3a4QmA/ZJwCLj+x5mrLRrKRf5LSjxHs+oNd1AsCz",
  watchers: []

# Enable dev routes for dashboard and mailbox
config :cumbuca, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
