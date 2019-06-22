defmodule Londibot.NotificationFactoryTest do
  use ExUnit.Case

  alias Londibot.NotificationFactory
  alias Londibot.Subscription
  alias Londibot.TelegramNotification
  alias Londibot.SlackNotification

  test "creates a telegram notification" do
    s = %Subscription{service: :telegram, channel_id: "123"}

    assert %TelegramNotification{message: "Hey!", channel_id: "123"} ==
             NotificationFactory.create(s, "Hey!")
  end

  test "creates a slack notification" do
    s = %Subscription{service: :slack, channel_id: "123"}

    assert %SlackNotification{message: "Hey!", channel_id: "123"} ==
             NotificationFactory.create(s, "Hey!")
  end
end
