defmodule BagelTracker.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias BagelTracker.Artist

  schema "events" do
    field :bit_id, :string
    field :datetime, :naive_datetime
    field :description, :string
    field :lineup, :string
    field :url, :string
    belongs_to :artist, Artist

    timestamps()
  end
  
  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:artist_id, :datetime, :description, :bit_id, :lineup, :url])
    |> validate_required([:artist_id, :datetime, :description, :bit_id, :lineup, :url])
  end

  @doc """
    Gets all events that are scheduled for a week out.
  """
  def get_upcoming_events do

  end

  @doc """
    imports new events from BIT
  """
  def import_new_events() do

  end
end
