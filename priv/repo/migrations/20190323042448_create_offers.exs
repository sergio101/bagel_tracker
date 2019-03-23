defmodule BagelTracker.Repo.Migrations.CreateOffers do
  use Ecto.Migration

  def change do
    create table(:offers) do
      add :status, :string
      add :type, :string
      add :url, :string

      timestamps()
    end

  end
end
