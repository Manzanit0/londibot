defmodule Londibot.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Service up and running!!"))
  post("/summary", do: send_resp(conn, 200, Londibot.Controller.report_all(:summary)))
  post("/disruptions", do: send_resp(conn, 200, Londibot.Controller.report_all(:disruptions)))

  match(_, do: send_resp(conn, 404, "Nothing found here!"))
end
