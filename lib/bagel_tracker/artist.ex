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

  @doc
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:facebook_page_url, :bit_id, :image_url, :mbid, :name, :thumb_url, :url])
    |> validate_required([:facebook_page_url, :bit_id, :image_url, :mbid, :name, :thumb_url, :url])
  end

  def find_by_mbid(mbid_entry) do
    query = from(a in "artists", select: a.mbid, where: a.mbid == ^mbid_entry )
    record = Repo.all(query)
  end

  def find_or_create_by_name(artist_name) do
    query = from(a in "artists", select: a.mbid, where: a.name == ^artist_name )
    case Repo.all(query) do
      [] -> Repo.insert(%Artist{name: artist_name})
      _ -> {:ok, :data_exists}
    end
  end


end
