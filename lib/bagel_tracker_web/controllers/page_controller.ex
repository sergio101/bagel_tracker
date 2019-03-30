defmodule BagelTrackerWeb.PageController do
  use BagelTrackerWeb, :controller
  alias BagelTracker.Router
  alias BagelTracker.Event

  def index(conn, params) do
    render(conn, "index.html")
  end

  def process_search(conn, params) do
    if params["search_term"] && params["range"] do
      events =
        GoogleGeocodingApi.geo_location(params["search_term"])
        |> Event.events_for_distance(String.to_integer(params["range"]) )
      IO.inspect length(events)
    end
    render(conn, "index.html")
  end
end
