defmodule BagelTracker.FetchRemoteData do
  @moduledoc """

  Fetches raw data from the server. parses it, and sends back a list of tuples of
  {artist, play_count)

  """
  alias BagelTracker.RawDataEntry

  @doc """
   Runs all functions and returns the list of tuples
  """
  def fetch_data() do
    'http://somafm.com/bagel/allartists.inc'
    |> get_html_data()
    |> check_or_insert_data
  end

  @doc """
    Fetches the data from the server
  """
  def get_html_data(url) do
    resp = :httpc.request(:get, {url, []}, [], [])
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} = resp
    body
  end

  def check_or_insert_data(body_data) do
    hash = :crypto.hash(:md5 , body_data) |> Base.encode16()
    case RawDataEntry.find_by_hash(hash) do
      [] -> BagelTracker.Repo.insert(%RawDataEntry{hash: hash,
        fetched_date: NaiveDateTime.truncate(NaiveDateTime.utc_now, :second),
        raw_data: List.to_string(body_data)}) #  |> process_html_data |> parse_data_list
      _ -> {:ok, :record_exists}
    end
  end

  @doc """
    takes the html list and returns a set of tuples.
  """
  def process_html_data(raw_data_record) do
    %BagelTracker.RawDataEntry{raw_data: html} = raw_data_record
    {"ol", [], entries } = Floki.parse(html)
    for entry <- entries do
      {"li", [], [data]} = entry
      data
    end
  end

  @doc"""
    takes a data list, and returns a list of {artist, count} tuples
  """
  def parse_data_list(data_list) do
    results = for entry <- data_list do
      IO.puts entry
    [ _, artist, play_count] = Regex.run(~r/(.*?)\s*\((.*?)\)/, entry)
    {artist, String.to_integer(play_count)}
    end
    results
  end

end
