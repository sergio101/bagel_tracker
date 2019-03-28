defmodule BagelTracker.Repo.Migrations.UpdateEventsArtistId do
  use Ecto.Migration

  def change do
    alter table(:events) do
      remove :artist_id
      add :artist_id, :integer
    end
  end
end
