defmodule LondibotWeb.Router do
  use LondibotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug(Plug.Logger, log: :debug)
    plug(LondibotWeb.DefaultHeadersPlug)
  end

  scope "/", LondibotWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/dashboard", DashboardController, :index
  end

  scope "/api", LondibotWeb do
    pipe_through :api

    # get("/", do: send_resp(conn, 200, "Service up and running!!"))
    post "/telegram", TelegramController, :post
    post "/slack", SlackController, :post
  end
end
