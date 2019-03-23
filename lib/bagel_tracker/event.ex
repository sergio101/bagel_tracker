defmodule BagelTracker.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :artist_id, :string
    field :bit_id, :string
    field :datetime, :naive_datetime
    field :description, :string
    field :lineup, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:artist_id, :datetime, :description, :bit_id, :lineup, :url])
    |> validate_required([:artist_id, :datetime, :description, :bit_id, :lineup, :url])
  end
end
