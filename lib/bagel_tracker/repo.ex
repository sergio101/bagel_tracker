defmodule BagelTracker.Repo do
  use Ecto.Repo,
    otp_app: :bagel_tracker,
    adapter: Ecto.Adapters.Postgres
end
