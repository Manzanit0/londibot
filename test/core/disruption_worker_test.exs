defmodule Londibot.DisruptionWorkerTest do
  use ExUnit.Case, async: true

  import Mox

  alias Londibot.DisruptionWorker
  alias Londibot.Subscription
  alias Londibot.Notification

  test "generates notifications for two subscriptions to the same disruption" do
    EnvironmentSetup.new()
    |> EnvironmentSetup.with_subscription(2, "456RTY", ["Victoria"])
    |> EnvironmentSetup.with_subscription(1, "123QWE", ["Victoria"])
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
    Application.get_env(:londibot, :subscription_store)
    |> expect(
      :all,
      fn ->
        [
          %Subscription{id: 1, channel_id: "123QWE", tfl_lines: ["Circle"]},
          %Subscription{id: 2, channel_id: "456RTY", tfl_lines: ["Victoria"]}
        ]
      end
    )

    notifications =
      [{"Victoria", "Minor delays", "..."}, {"Circle", "Minor delays", "..."}]
      |> DisruptionWorker.create_notifications()

    assert notifications == [
             %Notification{message: "Victoria: Minor delays", channel_id: "456RTY"},
             %Notification{message: "Circle: Minor delays", channel_id: "123QWE"}
           ]
  end

  test "prompts TFL for disruptions and generates notifications" do
    Application.get_env(:londibot, :subscription_store)
    |> expect(
      :all,
      fn ->
        [
          %Subscription{id: 1, channel_id: "123QWE", tfl_lines: ["Circle"]},
          %Subscription{id: 2, channel_id: "456RTY", tfl_lines: ["Victoria"]}
        ]
      end
    )

    Application.get_env(:londibot, :tfl_service)
    |> expect(:lines, fn -> ["victoria", "circle"] end)
    |> expect(:status, fn _ ->
      [{"Victoria", "Good Service", nil}, {"Circle", "Minor Delays", "Due to blablabla"}]
    end)
    |> expect(:disruptions, fn _ -> [{"Circle", "Minor Delays", "Due to blablabla"}] end)

    notifications = DisruptionWorker.disruption_notifications()

    assert notifications == [%Notification{message: "Circle: Minor Delays", channel_id: "123QWE"}]
  end
end
