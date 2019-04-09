defmodule BagelTracker.Statistic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "statistics" do
    field :key, :string
    field :name, :string
    field :value, :integer

    timestamps()
  end

  @doc false
  def changeset(statistic, attrs) do
    statistic
    |> cast(attrs, [:name, :key, :value])
    |> validate_required([:name, :key, :value])
  end
end
