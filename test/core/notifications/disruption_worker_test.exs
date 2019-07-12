defmodule Londibot.DisruptionWorkerTest do
  use ExUnit.Case

  import Mox

  alias Londibot.DisruptionWorker
  alias Londibot.SlackNotification, as: Notification

  setup :set_mox_global

  test "generates notifications for two subscriptions to the same disruption" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Victoria")
    |> World.create()

    notifications =
      [{"Victoria", "Bad Service", "..."}]
      |> DisruptionWorker.create_notifications()

    assert notifications == [
             %Notification{message: "...", channel_id: "123QWE"},
             %Notification{message: "...", channel_id: "456RTY"}
           ]
  end

  test "generates notifications for two subscriptions to different disruptions" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Circle")
    |> World.create()

    notifications =
      [
        {"Victoria", "Minor delays", "victoria - delay"},
        {"Circle", "Minor delays", "circle - delay"}
      ]
      |> DisruptionWorker.create_notifications()

    assert notifications == [
             %Notification{message: "victoria - delay", channel_id: "456RTY"},
             %Notification{message: "circle - delay", channel_id: "123QWE"}
           ]
  end

  test "prompts TFL for disruptions and generates notifications" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Circle")
    |> World.with_disruption(line: "Circle", status: "Minor Delays", description: "...")
    |> World.create()

    notifications = DisruptionWorker.disruption_notifications()

    assert notifications == [%Notification{message: "...", channel_id: "123QWE"}]
  end

  test "sends notifications based on existing disruptions" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Circle")
    |> World.with_disruption(line: "Circle", status: "Minor Delays", description: "...")
    |> World.with_notifications(1)
    |> World.create()

    DisruptionWorker.handle_info(:work, %{forever: false, minutes: nil})

    Mox.verify!(Londibot.NotifierMock)
  end

  test "sends notifications asynchronously" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Circle")
    |> World.with_subscription(3, "123QWE", "Circle")
    |> World.with_disruption(line: "Circle", status: "Minor Delays", description: "...")
    |> World.with_notifications(2)
    |> World.create()

    DisruptionWorker.start_link(forever: false, minutes: 0.001)

    # I felt it was better to sleep the thread 100 ms to wait for it
    # to finish rather than not testing it.
    :timer.sleep(100)

    Mox.verify!(Londibot.NotifierMock)
  end
end
