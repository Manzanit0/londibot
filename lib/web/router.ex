defmodule Londibot.Router do
  use Plug.Router

  alias Londibot.Commands.CommandRunner
  alias Londibot.Web.SubscriptionHandler

  plug Londibot.Web.DefaultHeadersPlug
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Service up and running!!"))

  post "/slack" do
    case Londibot.Web.SlackHandler.handle(conn) do
      {:error, msg} -> send_resp(conn, 200, "I'm sorry! #{msg}")
      msg -> send_resp(conn, 200, msg)
    end
  end

  match(_, do: send_resp(conn, 404, "Nothing found here!"))
end
