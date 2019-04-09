defmodule BagelTracker.Statistic do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias BagelTracker.Event
  alias BagelTracker.Artist
  alias BagelTracker.Statistic
  alias BagelTracker.Repo

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

  def update_counts() do
    for entry <- [{Artist, "artists_tracked"}, {Event, "events_tracked"}] do
      {model, key} = entry
      q = from(s in Statistic, where: s.key == ^key)
      changes = Statistic.changeset(Repo.one(q), %{value: Repo.aggregate(model, :count, :id)})
      Repo.update(changes)
    end
  end
end
