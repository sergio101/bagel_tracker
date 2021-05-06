# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bagel_tracker,
  ecto_repos: [BagelTracker.Repo]

# Configures the endpoint
config :bagel_tracker, BagelTrackerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HwDUAOOHMQY5tKYLLZx9LhAXx7lzEP47mg63cIDsPSBkqA32cMSYO5Gn4NsAgcKg",
  render_errors: [view: BagelTrackerWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: BagelTracker
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :google_geocoding_api,
       api_key: System.get_env("GEOAPI_KEY")