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
    field :is_active, :boolean
    belongs_to :artist, Artist
    has_one :venue, BagelTracker.Venue, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:artist_id, :datetime, :description, :bitid, :lineup, :url, :is_active])
    |> validate_required([:artist_id, :datetime, :bitid, :lineup, :url])
    |> unique_constraint(:bitid, name: :events_bitid_index)
  end

  @doc """
    imports new events from BIT
  """
  def import_new_events(artist_name) do
    remote_event = BandsInTownAPI.fetch_event_info(artist_name)
    case remote_event do
      {:ok, %{errorMessage: errorMessage}} -> IO.puts "There were errors"
      {:error, errors} -> IO.puts "There were errors"
      {:ok, events} -> process_remote_events(events)
    end
  end

  def process_remote_events(remote_events) do
    for event <- remote_events do
      artist_id = Repo.one(from a in Artist, select: a.id, where: a.bit_id == ^to_string(event.artist_id), limit: 1)
      {:ok, date_time} =  NaiveDateTime.from_iso8601(event.datetime)
      data_struct = %{ event | artist_id: artist_id, datetime: date_time, id: nil} |> Map.put(:bitid, event.id) |>  Map.put(:is_active, false)
      changeset = changeset(%Event{},data_struct)
      case Repo.insert(changeset) do
        {:ok, new_event } -> add_venue(data_struct, new_event)
        {:error, error } -> IO.puts "there was an error: #{inspect(error)}"
      end
    end
  end

  @doc """
    Imports fresh events for every artist, then swaps them in for the current ones.

    New events are inserted with is_active = false. Only once every artist has been
    processed are the old (active) events deleted and the new ones activated, in a
    single transaction. If the run dies partway, the site keeps showing the previous
    data, and the next run clears the half-imported rows before it starts.
  """
  def import_remote_events do
    delete_events_where(false)

    artist_names = Repo.all(from(a in Artist, select: a.name, where: not(is_nil(a.bit_id))))
    for artist_name <- artist_names do
      try do
        import_new_events(artist_name)
      rescue
        error -> IO.puts "Failed to import events for #{artist_name}: #{Exception.message(error)}"
      end
    end

    Repo.transaction(fn ->
      delete_events_where(true)
      Repo.update_all(from(e in Event, where: e.is_active == false), set: [is_active: true])
    end)
  end

  defp delete_events_where(true), do: delete_events(from e in Event, where: e.is_active == true, select: e.id)
  defp delete_events_where(false), do: delete_events(from e in Event, where: e.is_active == false or is_nil(e.is_active), select: e.id)

  defp delete_events(event_ids) do
    Repo.delete_all(from v in Venue, where: v.event_id in subquery(event_ids))
    Repo.delete_all(from e in Event, where: e.id in subquery(event_ids))
  end

  def add_venue(event, new_event) do
    venue_data = event.venue
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
     query = from(e in Event, where: e.datetime > ^(Timex.now |> Timex.shift(days: -1)) and e.is_active == true, preload: [:venue, :artist], order_by: e.datetime )
     events = Repo.all(query)
     Enum.filter(events, fn(x) ->
       Distance.GreatCircle.distance(
         Map.values(geo_point) |> Enum.reverse() |> List.to_tuple,
         {x.venue.longitude, x.venue.latitude})
       <= radius * 1609.34 end)
  end

  def get_last_n(n) do
    query = from e in Event, where: e.is_active == true, limit: ^n, preload: [:artist, :venue]
    Repo.all(query)
  end

  def get_event(id), do: Repo.get!(Event, id)

end
