defmodule Londibot.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias Londibot.Web.SlackHandler
  alias Londibot.Web.TelegramHandler

  plug Plug.Logger, log: :debug
  plug Londibot.Web.DefaultHeadersPlug

  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json],
                     pass: ["text/*", "application/*"],
                     json_decoder: Poison

  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Service up and running!!"))

  post "/slack" do
    msg = SlackHandler.handle(conn)
    send_resp(conn, 200, msg)
  end

  post "/telegram" do
    msg = TelegramHandler.handle(conn)
    send_resp(conn, 200, msg)
  end

  match(_, do: send_resp(conn, 404, "Nothing found here!"))


  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    IO.inspect(kind, label: :kind)
    IO.inspect(reason, label: :reason)
    IO.inspect(stack, label: :stack)
    send_resp(conn, conn.status, "Something went wrong")
  end
end
