defmodule BagelTracker.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "venues" do
    field :city, :string
    field :country, :string
    field :latitude, :float
    field :longitude, :float
    field :name, :string
    field :region, :string

    timestamps()
  end

  @doc false
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:city, :country, :latitude, :longitude, :name, :region])
    |> validate_required([:city, :country, :latitude, :longitude, :name, :region])
  end
end
