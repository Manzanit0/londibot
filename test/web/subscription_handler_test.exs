defmodule Londibot.Web.SubscriptionHandlerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Londibot.Web.SubscriptionHandler
  alias Londibot.Subscription

  test "subscription saved message is encoded to JSON" do
    expected = "{\"text\":\"Subscription saved!\",\"response_type\":\"in_channel\"}"
    assert expected == SubscriptionHandler.subscription_saved_message()
  end

  test "parses body params to subscription" do
    body_params = %{"channel_id" => "234", "text" => "victoria,london overground"}

    expected = %Subscription{channel_id: "234", tfl_lines: ["victoria", "london overground"]}
    assert expected == SubscriptionHandler.to_subscription(body_params)
  end

  test "creates subscription" do
    World.new()
    |> World.create()

    message =
      conn(:post, "/", %{"channel_id" => "123", "text" => "victoria"})
      |> SubscriptionHandler.handle()

    assert message == SubscriptionHandler.subscription_saved_message()
  end
end
