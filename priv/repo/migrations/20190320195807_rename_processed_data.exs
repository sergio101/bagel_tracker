defmodule BagelTracker.Repo.Migrations.RenameProcessedData do
  use Ecto.Migration

  def change do
    rename table(:raw_data_entries), :processed_data, to: :processed_date
  end
end
