defmodule BagelTracker.Repo.Migrations.AddActiveToEvent do
  use Ecto.Migration

  def change do
    alter table(:events) do
    add :is_active, :boolean
    end

    drop index :events, :bitid

  end
end
