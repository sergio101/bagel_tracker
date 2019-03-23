defmodule BagelTracker.Offer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "offers" do
    field :status, :string
    field :type, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(offer, attrs) do
    offer
    |> cast(attrs, [:status, :type, :url])
    |> validate_required([:status, :type, :url])
  end
end
