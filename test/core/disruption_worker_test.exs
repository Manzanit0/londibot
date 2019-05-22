defmodule Londibot.DisruptionWorkerTest do
  use ExUnit.Case, async: true

  alias Londibot.DisruptionWorker
  alias Londibot.Notification

  test "generates notifications for two subscriptions to the same disruption" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Victoria")
    |> World.with_disruption("Victoria", "Bad Service", "...")
    |> World.create()

    notifications =
      [{"Victoria", "Bad Service", "..."}]
      |> DisruptionWorker.create_notifications()

    assert notifications == [
             %Notification{message: "Victoria: Bad Service", channel_id: "123QWE"},
             %Notification{message: "Victoria: Bad Service", channel_id: "456RTY"}
           ]
  end

  test "generates notifications for two subscriptions to different disruptions" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Circle")
    |> World.with_disruption("Victoria", "Bad Service", "...")
    |> World.create()

    notifications =
      [{"Victoria", "Minor delays", "..."}, {"Circle", "Minor delays", "..."}]
      |> DisruptionWorker.create_notifications()

    assert notifications == [
             %Notification{message: "Victoria: Minor delays", channel_id: "456RTY"},
             %Notification{message: "Circle: Minor delays", channel_id: "123QWE"}
           ]
  end

  test "prompts TFL for disruptions and generates notifications" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Circle")
    |> World.with_disruption("Circle", "Minor Delays", "...")
    |> World.create()

    notifications = DisruptionWorker.disruption_notifications()

    assert notifications == [%Notification{message: "Circle: Minor Delays", channel_id: "123QWE"}]
  end

  test "sends notifications based on existing disruptions" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Circle")
    |> World.with_disruption("Circle", "Minor Delays", "...")
    |> World.with_notifications(1)
    |> World.create()

    DisruptionWorker.run(forever: false)

    Mox.verify!(Londibot.NotifierMock)
  end

  test "sends notifications asynchronously" do
    World.new()
    |> World.with_subscription(2, "456RTY", "Victoria")
    |> World.with_subscription(1, "123QWE", "Circle")
    |> World.with_subscription(3, "123QWE", "Circle")
    |> World.with_disruption("Circle", "Minor Delays", "...")
    |> World.with_notifications(2)
    |> World.create()

    DisruptionWorker.start_link(forever: false)

    # Since supervised tasks cannot be awaited, I felt it was better
    # to sleep the thread 1000 ms to wait for it to finish rather than
    # not testing it.
    :timer.sleep(1000)

    Mox.verify!(Londibot.NotifierMock)
  end
end
