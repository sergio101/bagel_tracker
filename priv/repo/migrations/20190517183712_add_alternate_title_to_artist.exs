defmodule BagelTracker.Repo.Migrations.AddAlternateTitleToArtist do
  use Ecto.Migration

  def change do
    alter table(:artists) do
      add :alternate_title, :string
    end
  end
end
