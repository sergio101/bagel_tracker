defmodule BagelTracker.ProcessRemoteData do
  @moduledoc """
    This file processes the remote data. It takes a list of tuples, and creates:

    - A processed data entry
    - A TrackedArtist, if required
    - Updates tracked artist with a count of the play_count

  """

  alias BagelTracker.FetchRemoteData
  alias BagelTracker.Artist


  def update_artists(data_list) do
    for entry <- data_list do
      {artist_name, play_count} = entry
      Artist.find_or_create_by_name(artist_name)
    end
  end


end
