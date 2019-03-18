defmodule Londibot.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Service up and running!"))

  get("/report") do
    message = Londibot.TFL.lines
    |> Londibot.TFL.status
    |> Enum.map(fn {name, status, _ } -> ~s("#{name}: #{status}") end)
    |> Enum.join("\n")

    send_resp(conn, 200, message)
  end

  match(_, do: send_resp(conn, 404, "Nothing found here!"))
end
