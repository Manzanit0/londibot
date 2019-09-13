defmodule Londibot.DisruptionActionsTest do
  use ExUnit.Case

  alias Londibot.DisruptionActions
  alias Londibot.StatusBroker
  alias Londibot.SlackNotification, as: Notification

  describe "create_notifications/0" do
    test "notifications are created according to status changes" do
      World.new()
      |> World.with_subscription("1", "123", "victoria")
      |> World.with_disruption(
        line: "victoria",
        status: "Severe Delays",
        starts_after: 1,
        lasts_for: 1
      )
      |> World.create()

      StatusBroker.start_link()

      notifications = DisruptionActions.create_notifications()

      assert [
               %Notification{
                 channel_id: "123",
                 message:
                   "⚠️ *victoria* line status has changed from Good Service to *Severe Delays*"
               }
             ] == notifications

      notifications = DisruptionActions.create_notifications()

      assert [
               %Londibot.SlackNotification{
                 channel_id: "123",
                 message: "✅ victoria line status has changed from Severe Delays to Good Service"
               }
             ] == notifications
    end
  end
end
