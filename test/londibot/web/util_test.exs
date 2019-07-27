defmodule Londibot.Web.UtilTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Londibot.Web.Util

  test "adds application/json header to conn" do
    header =
      %Plug.Conn{}
      |> Util.with_json_headers()
      |> Plug.Conn.get_resp_header("content-type")

    assert header == ["application/json; charset=utf-8"]
  end

  test "updates application/json header to conn" do
    header =
      %Plug.Conn{}
      |> Util.with_header("content-type", "some-value")
      |> Util.with_json_headers()
      |> Plug.Conn.get_resp_header("content-type")

    assert header == ["some-value; application/json; charset=utf-8"]
  end
end
