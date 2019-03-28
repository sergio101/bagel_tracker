defmodule BagelTracker.Repo.Migrations.UpdateEventsChangeDescription do
  use Ecto.Migration

  def change do
    alter table(:events) do
      modify :description, :text
    end
  end
end
