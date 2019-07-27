defmodule Londibot.Web.DefaultHeadersPlug do
  def init([]), do: false

  def call(conn, _opts) do
    conn
    |> Plug.Conn.fetch_query_params()
    |> with_json_headers()
  end

  def with_json_headers(conn = %Plug.Conn{}) do
    with_header(conn, "content-type", "application/json; charset=utf-8")
  end

  def with_header(conn = %Plug.Conn{}, key, value) do
    Plug.Conn.update_resp_header(
      conn,
      key,
      value,
      &(&1 <> "; " <> value)
    )
  end
end
