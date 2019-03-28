defmodule BagelTracker.Repo.Migrations.UpdateEventsBitidConstraint do
  use Ecto.Migration

  def change do
    drop index(:events, :bit_id)
    create unique_index(:events, [:bit_id])
  end
end
