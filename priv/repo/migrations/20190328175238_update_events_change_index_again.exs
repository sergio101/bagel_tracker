defmodule BagelTracker.Repo.Migrations.UpdateEventsChangeIndexAgain do
  use Ecto.Migration

  def change do
    create unique_index(:events, [:bitid])
  end
end
