defmodule Londibot.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Service up and running!"))
  get("/report", do: send_resp(conn, 200, Londibot.Controller.report_all))

  match(_, do: send_resp(conn, 404, "Nothing found here!"))
end
