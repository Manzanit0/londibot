defmodule Londibot.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Londibot.Router

  @opts Router.init([])

  test "returns welcome" do
    conn =
      conn(:get, "/", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns tfl status report" do
    conn =
      conn(:get, "/report")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    # Assert that the body contains 14 tube lines.
    assert length(String.split(conn.resp_body, "\n")) == 14
  end

  test "returns 404" do
    conn =
      conn(:get, "/missing", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
