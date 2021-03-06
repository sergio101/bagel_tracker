defmodule UpdateSiteData do

  import Ecto.Query
  import Ecto.Repo
  import Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  This is the entry point for updating all of the data in teh entire site.
  """

  alias BagelTracker.Repo
  alias BagelTracker.RawDataEntry
  alias BagelTracker.FetchRemoteData
  alias BagelTracker.ProcessRemoteData
  alias BagelTracker.Event
  alias BagelTracker.Artist
  alias BagelTracker.Venue

  @doc"""
    First, Gather up the raw data that has not been processed yet.
  """
  def start_data_update() do
    FetchRemoteData.fetch_data()
    case Repo.all(from(r in RawDataEntry, where: is_nil(r.processed_date))) do
      [] -> {:ok, :no_data_to_update}
      items -> process_data_entries(items)
    end
    IO.puts "Starting second phase of updates"
    BagelTracker.Artist.check_remote_data()
    BagelTracker.Event.import_remote_events()
    BagelTracker.Statistic.update_counts();
  end

  def process_data_entries(items) do

    for item <- items do
      IO.puts "Here is one item in the entries"
      IO.inspect item
      item
      |> FetchRemoteData.process_html_data
      |> FetchRemoteData.parse_data_list
      |> ProcessRemoteData.update_artists
      changeset = RawDataEntry.changeset(item, %{processed_date: NaiveDateTime.truncate(NaiveDateTime.utc_now, :second)})
      Repo.update(changeset)
    end
  end

  def clear_transient_data() do
    Repo.delete_all(Artist)
    Repo.delete_all(Event)
    Repo.delete_all(Venue)
  end

end
