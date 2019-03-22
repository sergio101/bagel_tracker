defmodule BagelTracker.RawDataEntry do
  @moduledoc """
  Creates new raw data entries if required
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import Ecto.Repo

  alias BagelTracker.RawDataEntry
  alias BagelTracker.Repo


  schema "raw_data_entries" do
    field :fetched_date, :naive_datetime
    field :hash, :string
    field :processed_date, :naive_datetime
    field :raw_data, :string

    timestamps()
  end

  @doc false
  def changeset(raw_data_entry, attrs) do
    raw_data_entry
    |> cast(attrs, [:fetched_date, :processed_date, :raw_data, :hash])
    |> validate_required([:fetched_date, :raw_data, :hash])
  end

  @doc """
    Checks to see if a record exists using the hash of the data
    If it doesn't, it inserts the record.
  """
  def find_by_hash(hash) do
        query = from(d in "raw_data_entries", select: d.hash, where: d.hash == ^hash )
        record = Repo.all(query)
  end

  def  process_data_entries do

  end

end
