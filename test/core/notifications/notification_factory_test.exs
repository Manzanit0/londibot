defmodule Londibot.NotificationFactoryTest do
  use ExUnit.Case

  alias Londibot.NotificationFactory
  alias Londibot.Subscription
  alias Londibot.TelegramNotification
  alias Londibot.SlackNotification
  alias Londibot.StatusChange

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

  test "creates a Slack notification from a StatusChange" do
    s = %Subscription{service: :slack, channel_id: "123"}
    c = %StatusChange{
        line: "victoria",
        previous_status: "Good Service",
        new_status: "Severe Delays",
        description: "Due to passenger not minding the gap"
      }

      notification = NotificationFactory.create(s, c)

      assert %SlackNotification{
        message: "victoria line status has changed from Good Service to Severe Delays (Due to passenger not minding the gap)",
        channel_id: "123"
      } == notification
  end

  test "creates a Telegram notification from a StatusChange" do
    s = %Subscription{service: :telegram, channel_id: "123"}
    c = %StatusChange{
        line: "victoria",
        previous_status: "Good Service",
        new_status: "Severe Delays",
        description: "Due to passenger not minding the gap"
      }

      notification = NotificationFactory.create(s, c)

      assert %TelegramNotification{
        message: "victoria line status has changed from Good Service to Severe Delays (Due to passenger not minding the gap)",
        channel_id: "123"
      } == notification
  end
end
