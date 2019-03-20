defmodule BagelTrackerWeb.PageController do
  use BagelTrackerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
