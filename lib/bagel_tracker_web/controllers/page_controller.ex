defmodule BagelTrackerWeb.PageController do
  use BagelTrackerWeb, :controller
  alias BagelTracker.Router
  alias BagelTracker.Event

  def index(conn, params) do
    render(conn, "index.html")
  end

  def process_search(conn, %{"search_term" => location, "range" => range}) do
    events =
      GoogleGeocodingApi.geo_location(location)
      |> Event.events_for_distance(String.to_integer(range) )
    render(conn, "index.html", events: events)
  end
end
