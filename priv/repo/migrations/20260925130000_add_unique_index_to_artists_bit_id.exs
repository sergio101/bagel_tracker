defmodule BagelTracker.Repo.Migrations.AddUniqueIndexToArtistsBitId do
  use Ecto.Migration

  def up do
    # Different band-list names can resolve to the same Bands in Town artist.
    # Keep the oldest artist for each bit_id and clear it on the rest.
    execute """
    UPDATE artists SET bit_id = NULL
    WHERE id IN (
      SELECT id FROM (
        SELECT id, row_number() OVER (PARTITION BY bit_id ORDER BY id) AS rn
        FROM artists WHERE bit_id IS NOT NULL
      ) ranked WHERE rn > 1
    )
    """

    create unique_index(:artists, [:bit_id])
  end

  def down do
    drop index(:artists, [:bit_id])
  end
end
