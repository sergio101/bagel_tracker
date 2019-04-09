defmodule BagelTracker.Repo.Migrations.CreateStatistics do
  use Ecto.Migration

  def change do
    create table(:statistics) do
      add :name, :string
      add :key, :string
      add :value, :integer

      timestamps()
    end

  end
end
