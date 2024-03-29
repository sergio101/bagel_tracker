use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bagel_tracker, BagelTrackerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :bagel_tracker, BagelTracker.Repo,
  username: "postgres",
  password: "postgres",
  database: "bagel_tracker_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
