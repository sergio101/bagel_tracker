defmodule BagelTracker.Repo.Migrations.UpdateEventsLineup do
  use Ecto.Migration

  def change do

    alter table(:events) do
      remove :lineup
      add :lineup, {:array, :string}
    end
    create index :events, :bit_id
    create index :artists, [:name, :bit_id ]
  end
end
