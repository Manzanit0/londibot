defmodule Londibot.Web.DefaultHeadersPlug do
  alias Londibot.Web.Util

  def init([]), do: false

  def call(conn, _opts) do
    conn
    |> Plug.Conn.fetch_query_params()
    |> Util.with_json_headers()
  end
end
