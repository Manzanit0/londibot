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

  test "returns 404" do
    conn =
      conn(:get, "/missing", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  describe "/subscription" do
    test "returns success message" do
      World.new()
      |> World.create()

      conn =
        conn(:post, "/subscription", %{channel_id: "123", text: "aaa"})
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200

      expected = {
        200,
        [{"cache-control", "max-age=0, private, must-revalidate"}],
        "{\"text\":\"Subscription saved!\",\"response_type\":\"in_channel\"}"}
      assert expected == Plug.Test.sent_resp(conn)
    end
  end
end
