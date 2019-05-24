defmodule Londibot.Web.SubscriptionHandlerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Londibot.Web.SubscriptionHandler

  test "creates subscription" do
    World.new()
    |> World.create()

    message =
      conn(:post, "/subscription?q=new", %{"channel_id" => "123", "text" => "victoria"})
      |> Plug.Conn.fetch_query_params()
      |> SubscriptionHandler.handle()

    assert message == "{\"text\":\"Subscription saved!\",\"response_type\":\"in_channel\"}"
  end

  test "fetches all subscriptions" do
    World.new()
    |> World.with_subscription(1, "123", "victoria")
    |> World.with_subscription(2, "123", "northern")
    |> World.with_subscription(3, "456", "circle")
    |> World.create()

    message =
      conn(:post, "/subscription?q=all", %{"channel_id" => "123", "text" => ""})
      |> Plug.Conn.fetch_query_params()
      |> SubscriptionHandler.handle()

    assert message ==
      "{\"text\":\"You are currently subscribed to: northern, victoria\",\"response_type\":\"in_channel\"}"
  end

  test "no subscriptions available upon fetch" do
    World.new()
    |> World.with_subscription(1, "123", "victoria")
    |> World.with_subscription(2, "123", "northern")
    |> World.with_subscription(3, "456", "circle")
    |> World.create()

    message =
      conn(:post, "/subscription?q=all", %{"channel_id" => "987", "text" => ""})
      |> Plug.Conn.fetch_query_params()
      |> SubscriptionHandler.handle()

    assert message ==
      "{\"text\":\"You are currently not subscribed to any line\",\"response_type\":\"in_channel\"}"
  end
end
