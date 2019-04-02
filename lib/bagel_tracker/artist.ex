defmodule BagelTracker.Artist do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import Ecto.Repo

  alias BagelTracker.Repo
  alias BagelTracker.Artist
  alias BagelTracker.Event

  schema "artists" do
    field :bit_id, :string
    field :facebook_page_url, :string
    field :image_url, :string
    field :mbid, :string
    field :name, :string
    field :thumb_url, :string
    field :url, :string
    has_many :events, Event

    timestamps()
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
    query = from(a in Artist, where: a.name == ^name )
    case Repo.all(query) do
      [] -> Repo.insert(%Artist{name: name})
      _ -> {:ok, :data_exists}
    end
  end

  @doc """
  This is the entry point of hte function. This will update any artist that do not
  have any BIT info.
  """

  def check_remote_data do
    query = from(a in Artist, where: is_nil(a.bit_id) )
    for artist<- Repo.all(query) do
      update_artist(artist)
    end
  end

  def update_artist(artist) do
    {:ok, artist_info} = BandsInTownAPI.fetch_artist_info(artist.name)
    case  artist_info do

      %{error: "Not Found"} -> {:ok, :artist_doesnt_exist}
      "" -> {:ok, :blank_returned}
      artist_info -> Repo.update(changeset(artist,  artist_info |> Map.put(:bit_id, artist_info.id)))
    end
  end

  @doc """
    Gets artists that have an entry in the database. This assures that they exists.
  """
  def get_active_artists do
    query = from(a in "artists", where: not(is_nil(a.bit_id)))
    Repo.all(query)
  end

end