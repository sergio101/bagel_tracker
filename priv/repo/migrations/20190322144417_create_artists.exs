defmodule BagelTracker.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :facebook_page_url, :string
      add :bit_id, :string
      add :image_url, :string
      add :mbid, :string
      add :name, :string
      add :thumb_url, :string
      add :url, :string

      timestamps()
    end

  end
end
