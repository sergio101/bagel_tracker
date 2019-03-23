defmodule BandsInTownAPI do
  @moduledoc """
    This is a Bands in Town API
  """

  @api_key  System.get_env("BIT_KEY")
  @rest_url "https://rest.bandsintown.com"

  @doc"""
    Fetches the artist info from Bands in Town. Note that you must have your API key
    set as an environment variable.
  """
  def fetch_artist_info(artist_name) do
    api_path = "#{@rest_url}/artists/#{URI.encode(String.replace(artist_name,"/","%2F"))}?app_id=#{@api_key}"
    IO.inspect URI.encode(artist_name)
    case HTTPoison.get(api_path) do
      {:ok, %{body: raw}} -> raw |> parse_data()
      {:error, %{reason: reason} } -> {:error, reason}
    end
  end

  def parse_data(body_data) do
    Poison.decode(body_data, keys: :atoms)
  end

end
