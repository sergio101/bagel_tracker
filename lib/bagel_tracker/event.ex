defmodule BagelTracker.Event do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias BagelTracker.Artist
  alias BagelTracker.Repo
  alias BagelTracker.Event

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
  def import_new_events(artist_name) do
    remote_event = BandsInTownAPI.fetch_event_info(artist_name)
    case remote_event do
      {:ok, events} -> process_remote_events(events)
    end
  end

  def process_remote_events(remote_events) do
    for event <- remote_events do
      query = from e in "events", select: e.id, where: e.bit_id == ^event.id
      case Repo.all(query) do
        [] -> insert_new_event(event)
      end
    end
  end

  def insert_new_event(event) do
    IO.inspect event
    IO.inspect Repo.one(from a in "artists", select: a.id, where: a.bit_id == ^event.artist_id)
    # event_record = %Event{bit_id: event.id}
  end
end
