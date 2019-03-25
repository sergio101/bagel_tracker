defmodule GeoCodeAPI do
  @moduledoc """
  GeoCodes a location string
"""

  @api_key  System.get_env("GEOAPI_KEY")

  def geocode_string(string) do
    "https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(string)}&key=#{@api_key}"
    |> fetch_data
  end

  def fetch_data(path) do
    case HTTPoison.get(path) do
      {:ok, %{body: raw}} -> raw |> parse_data
      {:error, %{reason: reason} } -> {:error, reason}
    end
  end

  def parse_data(body_data) do
    Poison.decode(body_data, keys: :atoms)
  end

end
