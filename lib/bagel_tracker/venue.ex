defmodule BagelTracker.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  alias BagelTracker.Event

  schema "venues" do
    field :city, :string
    field :country, :string
    field :latitude, :float
    field :longitude, :float
    field :name, :string
    field :region, :string
    belongs_to :event, Event

    timestamps()
  end

  @doc false
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:city, :country, :latitude, :longitude, :name, :region])
    |> validate_required([:city, :name])
  end
end
