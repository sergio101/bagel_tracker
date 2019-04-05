defmodule BagelTracker.GeoLocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "geo_locations" do
    field :latitude, :float
    field :longitude, :float
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(geo_location, attrs) do
    geo_location
    |> cast(attrs, [:name, :longitude, :latitude])
    |> validate_required([:name, :longitude, :latitude])
  end
end
