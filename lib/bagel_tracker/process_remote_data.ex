defmodule BagelTracker.ProcessRemoteData do
  @moduledoc """
    This file processes the remote data. It takes a list of tuples, and creates:

    - A processed data entry
    - A TrackedArtist, if required
    - Updates tracked artist with a count of the play_count

  """

  alias BagelTracker.FetchRemoteData

  @doc """
    Takes the data in the list, and performs each processing step on it.
  """

  def process_data() do
    data = FetchRemoteData.fetch_data()
    case  data do
      {:ok, :record_exists} -> {:ok, :no_processing_required}
      _ -> update_artists(data)
    end
  end

  def update_artists({:ok, data_list} = data) do
    IO.puts("about to output data list")
    IO.inspect data_list

  end

end
