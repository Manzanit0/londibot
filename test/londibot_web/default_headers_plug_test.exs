defmodule Londibot.Web.DefaultHeadersPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias LondibotWeb.DefaultHeadersPlug

  test "adds application/json header to conn" do
    header =
      %Plug.Conn{}
      |> DefaultHeadersPlug.with_json_headers()
      |> Plug.Conn.get_resp_header("content-type")

    assert header == ["application/json; charset=utf-8"]
  end

  test "updates application/json header to conn" do
    header =
      %Plug.Conn{}
      |> DefaultHeadersPlug.with_header("content-type", "some-value")
      |> DefaultHeadersPlug.with_json_headers()
      |> Plug.Conn.get_resp_header("content-type")

    assert header == ["some-value; application/json; charset=utf-8"]
  end
end
