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
    field :lineup, {:array, :string}
    field :url, :string
    belongs_to :artist, Artist

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:artist_id, :datetime, :description, :bit_id, :lineup, :url])
    |> validate_required([:artist_id, :datetime, :description, :bit_id, :lineup, :url])
    |> unique_constraint(:bit_id)
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
      artist_id = Repo.one(from a in Artist, select: a.id, where: a.bit_id == ^event.artist_id)
      {:ok, date_time} =  NaiveDateTime.from_iso8601(event.datetime)
      data_struct = struct(Event, %{ event | id: nil, artist_id: artist_id, datetime: date_time})
      Repo.insert(data_struct)
    end
  end
  
end
