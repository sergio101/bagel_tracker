defmodule ProcessRemoteData do
  @moduledoc """
    This file processes the remote data. It takes a list of tuples, and creates:

    - A processed data entry
    - A TrackedArtist, if required
    - Updates tracked artist with a count of the play_count

  """

  @doc """
    Takes the data in the list, and performs each processing step on it.
  """
  def process_data(data_list) do
    for data  <- data_list do
      {artist, play_count} = data
      update_artists(artist, play_count)
    end
  end

  def update_artists(artist, play_count) do
    # find artist by name, if doesn't exist, create it with play_count
    # if it does exist, add to the playcount
  end

end
