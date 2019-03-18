defmodule Londibot.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Service up and running!"))
  match(_, do: send_resp(conn, 404, "Nothing found here!"))
end
