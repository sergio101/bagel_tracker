defmodule BagelTracker.Repo.Migrations.CreateVenues do
  use Ecto.Migration

  def change do
    create table(:venues) do
      add :city, :string
      add :country, :string
      add :latitude, :float
      add :longitude, :float
      add :name, :string
      add :region, :string

      timestamps()
    end

  end
end
