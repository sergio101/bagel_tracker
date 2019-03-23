defmodule BagelTracker.Artist do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import Ecto.Repo

  alias BagelTracker.Repo
  alias BagelTracker.Artist

  schema "artists" do
    field :bit_id, :string
    field :facebook_page_url, :string
    field :image_url, :string
    field :mbid, :string
    field :name, :string
    field :thumb_url, :string
    field :url, :string

    timestamps()
  end

  @doc """
    This is where we store the artists
  """
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:facebook_page_url, :bit_id, :image_url, :mbid, :name, :thumb_url, :url])
    |> validate_required([:name])
  end

  def find_or_create_by_name(artist_name) do
    query = from(a in "artists", select: a.mbid, where: a.name == ^artist_name )
    case Repo.all(query) do
      [] -> Repo.insert(%Artist{name: artist_name})
      _ -> {:ok, :data_exists}
    end
  end

  @doc """
  This is the entry point of hte function. This will update any artsist that do not
  have any BIT info.
  """

  def check_remote_data do
    query = from(a in "artists", select: a.id, where: is_nil(a.bit_id) )
    for id <- Repo.all(query) do
      artist = Repo.get(Artist, id)
      update_artist(artist)
    end
  end

  def update_artist(artist) do
    {:ok, artist_info} = BandsInTownAPI.fetch_artist_info(artist.name)
    IO.puts "+++"
    IO.inspect artist_info
    IO.puts "+++"
    case artist_info do
      %{error: "Not Found"} -> {:ok, :artist_doesnt_exist}
      "" -> {:ok, :blank_returned}
      _ -> Repo.update(changeset(artist,  artist_info |> Map.put(:bit_id, artist_info.id)))
    end
  end

end