defmodule Londibot.Router do
  use Plug.Router

  alias Londibot.Web.Util
  alias Londibot.Web.SubscriptionHandler

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Service up and running!!"))
  post("/summary", do: send_resp(conn, 200, Londibot.Controller.report_all(:summary)))
  post("/disruptions", do: send_resp(conn, 200, Londibot.Controller.report_all(:disruptions)))

  post "/subscription" do
    message =
      conn
      |> Util.with_json_headers()
      |> SubscriptionHandler.handle()

    send_resp(conn, 200, message)
  end

  match(_, do: send_resp(conn, 404, "Nothing found here!"))
end
