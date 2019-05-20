defmodule BagelTrackerWeb.PageView do
  use BagelTrackerWeb, :view

  def render_artist_url(event) do
    if event.artist.url == nil,  do: "#", else: event.artist.url
  end
end
