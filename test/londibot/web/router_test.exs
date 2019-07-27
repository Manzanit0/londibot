defmodule Londibot.Web.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Londibot.Web.Router

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

  describe "/slack" do
    test "returns success message with correct headers" do
      World.new()
      |> World.create()

      conn =
        conn(:post, "/slack", %{channel_id: "123", text: "subscribe victoria"})
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200

      expected =
        {200,
         [
           {"cache-control", "max-age=0, private, must-revalidate"},
           {"content-type", "application/json; charset=utf-8"}
         ], "{\"text\":\"Subscription saved!\",\"response_type\":\"in_channel\"}"}

      assert expected == Plug.Test.sent_resp(conn)
    end
  end

  describe "/telegram" do
    test "returns success message with correct headers" do
      World.new()
      |> World.create()

      conn =
        conn(:post, "/telegram", %{
          "message" => %{"from" => %{"id" => "123"}, "text" => "/subscribe victoria"}
        })
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200

      expected =
        {200,
         [
           {"cache-control", "max-age=0, private, must-revalidate"},
           {"content-type", "application/json; charset=utf-8"}
         ],
         "{\"text\":\"Subscription saved!\",\"parse_mode\":\"markdown\",\"method\":\"sendMessage\",\"chat_id\":\"123\"}"}

      assert expected == Plug.Test.sent_resp(conn)
    end
  end

  describe "Inexistent endpoint" do
    test "returns success message with correct headers" do
      World.new()
      |> World.create()

      conn =
        conn(:post, "/inexistent", %{"message" => "some message"})
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 404

      expected =
        {404,
         [
           {"cache-control", "max-age=0, private, must-revalidate"},
           {"content-type", "application/json; charset=utf-8"}
         ], "Nothing found here!"}

      assert expected == Plug.Test.sent_resp(conn)
    end
  end
end
