defmodule BagelTrackerWeb.PageController do
  use BagelTrackerWeb, :controller
  alias BagelTracker.Router
  alias BagelTracker.Event
  alias BagelTracker.GeoLocation
  alias BagelTracker.Repo
  alias BagelTracker.Statistic

  def index(conn, params) do
    stats = Repo.all(Statistic)
    IO.inspect stats
    render(conn, "index.html", stats: stats)
  end

  def process_search(conn, %{"search_term" => location, "range" => range}) do
    geo_location = GoogleGeocodingApi.geo_location(location)
    stats = Repo.all(Statistic)
    %{"lat" => latitude, "lng" => longitude } = geo_location
    Repo.insert(%GeoLocation{name: location, latitude: latitude, longitude: longitude })
    events =
      geo_location
      |> Event.events_for_distance(String.to_integer(range) )
    render(conn, "index.html", %{events: events, stats: stats})
  end
end
