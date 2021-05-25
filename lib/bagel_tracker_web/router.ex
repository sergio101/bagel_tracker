defmodule BagelTrackerWeb.Router do
  use BagelTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BagelTrackerWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/process_search", PageController, :process_search
    get "/fetch_concerts/:location/:range", PageController, :fetch_concerts
    get "/test_locations", PageController, :test_locations
  end

  # Other scopes may use custom stacks.
  # scope "/api", BagelTrackerWeb do
  #   pipe_through :api
  # end
end
