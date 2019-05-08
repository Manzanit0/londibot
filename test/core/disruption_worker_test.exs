defmodule Londibot.DisruptionWorkerTest do
  use ExUnit.Case, async: true

  import Mox

  alias Londibot.DisruptionWorker
  alias Londibot.Subscription
  alias Londibot.Notification

  test "generates notifications for two subscriptions to the same disruption" do
    Application.get_env(:londibot, :subscription_store)
    |> expect(:all,
      fn -> [
        %Subscription{id: 1, channel_id: "123QWE", tfl_lines: ["Victoria"]},
        %Subscription{id: 1, channel_id: "456RTY", tfl_lines: ["Victoria"]}]
      end)

    notifications =
      [{"Victoria", "Bad Service", "..."}]
      |> DisruptionWorker.create_notifications

    assert notifications == [
      %Notification{message: "Victoria: Bad Service", channel_id: "123QWE"},
      %Notification{message: "Victoria: Bad Service", channel_id: "456RTY"}]
  end

  test "generates notifications for two subscriptions to different disruptions" do
    Application.get_env(:londibot, :subscription_store)
    |> expect(:all,
      fn -> [
        %Subscription{id: 1, channel_id: "123QWE", tfl_lines: ["Circle"]},
        %Subscription{id: 2, channel_id: "456RTY", tfl_lines: ["Victoria"]}]
      end)

    notifications =
      [{"Victoria", "Minor delays", "..."}, {"Circle", "Minor delays", "..."}]
      |> DisruptionWorker.create_notifications

    assert notifications == [
      %Notification{message: "Victoria: Minor delays", channel_id: "456RTY"},
      %Notification{message: "Circle: Minor delays", channel_id: "123QWE"}]
  end
end
