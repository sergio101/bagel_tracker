use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :bagel_tracker, BagelTrackerWeb.Endpoint,
  secret_key_base: System.get_env("BAGEL_SECRET")

# Configure your database
config :bagel_tracker, BagelTracker.Repo,
       username: "concert_finder",
       password: System.get_env("BAGEL_DB_PASSWORD"),
       database: "bagel_tracker_prod",
       pool_size: 15
