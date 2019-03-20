defmodule FetchRemoteData do
  @moduledoc """

  Fetches raw data from the server. parses it, and sends back a list of tuples of
  {artist, play_count)

  """


  @doc """
   Runs all functions and returns the list of tuples
  """
  def fetch_data() do
    'http://somafm.com/bagel/allartists.inc'
    |> get_html_data()
    |> process_html_data
    |> parse_data_list
  end

  @doc """
    Fetches the data from the server
  """
  def get_html_data(url) do
    resp = :httpc.request(:get, {url, []}, [], [])
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} = resp
    body
  end

  @doc """
    takes the html list and returns a set of tuples.
  """
  def process_html_data(html) do
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
    for entry <- data_list do
    [ _, artist, play_count] = Regex.run(~r/(.*?)\s*\((.*?)\)/, entry)
    {artist, String.to_integer(play_count)}
    end
  end

end
