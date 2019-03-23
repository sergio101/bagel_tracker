defmodule BagelTracker.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :artist_id, :string
      add :datetime, :naive_datetime
      add :description, :string
      add :bit_id, :string
      add :lineup, :string
      add :url, :string

      timestamps()
    end

  end
end
