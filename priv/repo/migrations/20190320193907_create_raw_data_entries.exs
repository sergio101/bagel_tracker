defmodule BagelTracker.Repo.Migrations.CreateRawDataEntries do
  use Ecto.Migration

  def change do
    create table(:raw_data_entries) do
      add :fetched_date, :naive_datetime
      add :processed_data, :naive_datetime
      add :raw_data, :text
      add :hash, :string

      timestamps()
    end

  end
end
