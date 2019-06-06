defmodule Londibot.Router do
  use Plug.Router

  alias Londibot.Web.SlackHandler

  plug Londibot.Web.DefaultHeadersPlug
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Service up and running!!"))

  post "/slack" do
    msg = SlackHandler.handle(conn)
    send_resp(conn, 200, msg)
  end

  match(_, do: send_resp(conn, 404, "Nothing found here!"))
end
