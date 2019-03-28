defmodule BagelTracker.Repo.Migrations.UpdateEventsArtistConstraints do
  use Ecto.Migration

  def change do
    create unique_index(:artists, [:name])
  end
end
