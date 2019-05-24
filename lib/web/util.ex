defmodule Londibot.Web.Util do
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
