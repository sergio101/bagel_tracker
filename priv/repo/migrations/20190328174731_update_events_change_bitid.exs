defmodule BagelTracker.Repo.Migrations.UpdateEventsChangeBitid do
  use Ecto.Migration

  def change do
      rename table(:events), :bit_id, to: :bitid
  end
end
