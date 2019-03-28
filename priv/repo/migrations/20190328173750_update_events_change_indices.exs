defmodule BagelTracker.Repo.Migrations.UpdateEventsChangeIndices do
  use Ecto.Migration

  def change do
    drop unique_index(:events, [:bit_id])
    create unique_index(:events, :bit_id, name: :events_bit_id_index)
  end
end
