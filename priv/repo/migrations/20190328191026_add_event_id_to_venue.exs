defmodule BagelTracker.Repo.Migrations.AddEventIdToVenue do
  use Ecto.Migration

  def change do
    alter table(:venues) do
      add :event_id, :integer
    end
  end
end
