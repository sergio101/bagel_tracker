defmodule BagelTracker.Artist do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import Ecto.Repo

  alias BagelTracker.Repo
  alias BagelTracker.Artist
  alias BagelTracker.Event
  alias BagelTracker.FetchRemoteData

  schema "artists" do
    field :bit_id, :string
    field :facebook_page_url, :string
    field :image_url, :string
    field :mbid, :string
    field :name, :string
    field :thumb_url, :string
    field :url, :string
    field :alternate_title, :string

    has_many :events, Event

    timestamps()
  end

  @doc """
    Finds new artists and adds them to the database
"""
  def process_new_artists do
    FetchRemoteData.read_band_list_file()
    |> BagelTracker.ProcessRemoteData.update_artists()

  end
  @doc """
    This is where we store the artists
  """
    def changeset(artist, attrs) do
      artist
      |> cast(attrs, [:facebook_page_url, :bit_id, :image_url, :mbid, :name, :thumb_url, :url])
      |> validate_required([:name])
      |> unique_constraint(:name)
      |> unique_constraint(:bit_id)

    end

  def find_or_create_by_name(artist_name) do
    name = String.trim(artist_name)

    # Use ilike for case-insensitive matching
    query = from(a in Artist, where: fragment("lower(?)", a.name) == fragment("lower(?)", ^name))

    case Repo.all(query) do
      [] -> Repo.insert(%Artist{name: name})
      [artist | _] -> {:ok, :data_exists}
    end
  end


  @doc """
  This is the entry point of the function. This will update any artist that do not
  have any BIT info.
  """

  def check_remote_data do
    query = from(a in Artist, where: is_nil(a.bit_id) )
    for artist<- Repo.all(query) do
      update_artist(artist)
    end
  end

  def update_artist(artist) do
    case BandsInTownAPI.fetch_artist_info(artist.name) do
      {:ok, %{error: "Not Found"}} -> {:ok, :artist_doesnt_exist}
      {:ok, ""} -> {:ok, :blank_returned}
      {:ok, %{id: bit_id} = artist_info} -> assign_bit_info(artist, to_string(bit_id), artist_info)
      other -> {:error, other}
    end
  end

  # Different band-list names can resolve to the same BIT artist
  # (e.g. "see night" / "SEE NIGHT"). Only the first one gets the bit_id.
  defp assign_bit_info(artist, bit_id, artist_info) do
    if Repo.exists?(from a in Artist, where: a.bit_id == ^bit_id and a.id != ^artist.id) do
      IO.puts "Skipping #{artist.name}: bit_id #{bit_id} already belongs to another artist"
      {:ok, :duplicate_bit_id}
    else
      Repo.update(changeset(artist, Map.put(artist_info, :bit_id, bit_id)))
    end
  end

  @doc """
    Gets artists that have an entry in the database. This assures that they exists.
  """
  def get_active_artists do
    query = from a in BagelTracker.Artist,
                 where: not is_nil(a.bit_id)

    BagelTracker.Repo.all(query)

  end

  def update_artists(data_list) do
    for entry <- data_list do
      Artist.find_or_create_by_name(entry)
    end
  end

end
