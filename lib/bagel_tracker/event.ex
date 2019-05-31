defmodule BagelTracker.Event do
  use Ecto.Schema
  use Timex
  import Ecto.Changeset
  import Ecto.Query

  alias BagelTracker.Artist
  alias BagelTracker.Repo
  alias BagelTracker.Event
  alias BagelTracker.Venue

  schema "events" do
    field :bitid, :string
    field :datetime, :naive_datetime
    field :description, :string
    field :lineup, {:array, :string}
    field :url, :string
    belongs_to :artist, Artist
    has_one :venue, BagelTracker.Venue

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:artist_id, :datetime, :description, :bitid, :lineup, :url])
    |> validate_required([:artist_id, :datetime, :bitid, :lineup, :url])
    |> unique_constraint(:bitid, name: :events_bitid_index)
  end

  @doc """
    imports new events from BIT
  """
  def import_new_events(artist_name) do
    remote_event = BandsInTownAPI.fetch_event_info(artist_name)
    IO.inspect remote_event
    case remote_event do
      {:ok, %{errorMessage: errorMessage}} -> IO.puts "There were errors"
      {:error, errors} -> IO.puts "There were errors"
      {:ok, events} -> process_remote_events(events)
    end
  end

  def process_remote_events(remote_events) do
    for event <- remote_events do
      artist_id = Repo.one(from a in Artist, select: a.id, where: a.bit_id == ^event.artist_id)
      {:ok, date_time} =  NaiveDateTime.from_iso8601(event.datetime)
      data_struct = %{ event | artist_id: artist_id, datetime: date_time, id: nil} |> Map.put(:bitid, event.id)
      changeset = changeset(%Event{},data_struct)
      IO.inspect changeset
      case Repo.insert(changeset) do
        {:ok, new_event } -> add_venue(data_struct, new_event)
        {:error, error } -> {:error, :could_not_insert}
      end
    end
  end

  def import_remote_events do
    artist_names = Repo.all(from(a in Artist, select: a.name, where: not(is_nil(a.bit_id))))
    for artist_name <- artist_names do
      import_new_events(artist_name)
    end
  end

  def add_venue(event, new_event) do
    venue_data = event.venue
#    data = %{venue_data | longitude: string_to_float(venue_data[:longitude]), latitude: string_to_float(venue_data[:latitude]) }
    data = venue_data
           |> Map.put(:longitude, string_to_float(venue_data[:longitude]))
           |> Map.put(:latitude, string_to_float(venue_data[:latitude]))
    venue = Ecto.build_assoc(new_event, :venue, data)
    Repo.insert(venue)
  end

  defp string_to_float(string) do
    if string, do: String.to_float(string), else: 0.0
  end

  def events_for_distance(geo_point, radius) do
     query = from(e in Event, where: e.datetime > ^(Timex.now |> Timex.shift(days: -1)), preload: [:venue, :artist], order_by: e.datetime )
     events = Repo.all(query)
     Enum.filter(events, fn(x) ->
       Distance.GreatCircle.distance(
         Map.values(geo_point) |> Enum.reverse() |> List.to_tuple,
         {x.venue.longitude, x.venue.latitude})
       <= radius * 1609.34 end)
  end


end
