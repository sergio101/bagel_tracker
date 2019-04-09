defmodule BagelTracker.Repo.Migrations.AddStatisticsToDatabase do
  use Ecto.Migration

  alias BagelTracker.Statistic

  def change do
    stats = [
      %Statistic{name: "Artists Tracked", key: "artists_tracked", value: 0},
      %Statistic{name: "Events Tracked", key: "events_tracked", value: 0},
    ]

    for stat <- stats do
      BagelTracker.Repo.insert(stat)
    end
  end
end
