defmodule BagelTracker.Repo.Migrations.CreateGeoLocations do
  use Ecto.Migration

  def change do
    create table(:geo_locations) do
      add :name, :string
      add :longitude, :float
      add :latitude, :float

      timestamps()
    end

  end
end
