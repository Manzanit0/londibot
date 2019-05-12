defmodule Londibot.DisruptionWorkerTest do
  use ExUnit.Case, async: true

  alias Londibot.DisruptionWorker
  alias Londibot.Notification

  test "generates notifications for two subscriptions to the same disruption" do
    EnvironmentSetup.new()
    |> EnvironmentSetup.with_subscription(2, "456RTY", "Victoria")
    |> EnvironmentSetup.with_subscription(1, "123QWE", "Victoria")
    |> EnvironmentSetup.with_disruption("Victoria", "Bad Service", "...")
    |> EnvironmentSetup.create()

    notifications =
      [{"Victoria", "Bad Service", "..."}]
      |> DisruptionWorker.create_notifications()

    assert notifications == [
             %Notification{message: "Victoria: Bad Service", channel_id: "123QWE"},
             %Notification{message: "Victoria: Bad Service", channel_id: "456RTY"}
           ]
  end

  test "generates notifications for two subscriptions to different disruptions" do
    EnvironmentSetup.new()
    |> EnvironmentSetup.with_subscription(2, "456RTY", "Victoria")
    |> EnvironmentSetup.with_subscription(1, "123QWE", "Circle")
    |> EnvironmentSetup.with_disruption("Victoria", "Bad Service", "...")
    |> EnvironmentSetup.create()

    notifications =
      [{"Victoria", "Minor delays", "..."}, {"Circle", "Minor delays", "..."}]
      |> DisruptionWorker.create_notifications()

    assert notifications == [
             %Notification{message: "Victoria: Minor delays", channel_id: "456RTY"},
             %Notification{message: "Circle: Minor delays", channel_id: "123QWE"}
           ]
  end

  test "prompts TFL for disruptions and generates notifications" do
    EnvironmentSetup.new()
    |> EnvironmentSetup.with_subscription(2, "456RTY", "Victoria")
    |> EnvironmentSetup.with_subscription(1, "123QWE", "Circle")
    |> EnvironmentSetup.with_disruption("Circle", "Minor Delays", "...")
    |> EnvironmentSetup.create()

    notifications = DisruptionWorker.disruption_notifications()

    assert notifications == [%Notification{message: "Circle: Minor Delays", channel_id: "123QWE"}]
  end
end
