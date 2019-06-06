defmodule Londibot.Router do
  use Plug.Router

  alias Londibot.Web.SubscriptionHandler

  plug Londibot.Web.DefaultHeadersPlug
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Service up and running!!"))
  post("/summary", do: send_resp(conn, 200, Londibot.Controller.report_all(:summary)))
  post("/disruptions", do: send_resp(conn, 200, Londibot.Controller.report_all(:disruptions)))
  post("/subscription", do: send_resp(conn, 200, SubscriptionHandler.handle(conn)))

  match(_, do: send_resp(conn, 404, "Nothing found here!"))
end
