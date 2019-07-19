defmodule Londibot.Commands.CommandRunnerTest do
  use ExUnit.Case, async: true

  alias Londibot.Commands.CommandRunner
  alias Londibot.Commands.Command

  test "formats line statuses as a report" do
    World.new()
    |> World.with_disruption(line: "Circle", status: "Minor Delays", description: "...")
    |> World.with_disruption(line: "Jubilee", status: "Closed", description: "...")
    |> World.create()

    {:ok, result} = CommandRunner.execute(%Command{command: :status})

    # World prints returns the information for all the lines.
    # The interesting thing to test here is that CommandRunner returns
    # a text with some of the info.
    assert String.contains?(result, "🚫 Jubilee: Closed\n")
    assert String.contains?(result, "⚠️ Circle: Minor Delays\n")
    assert String.contains?(result, "✅ victoria: Good Service\n")
  end

  test "formats disruptions as a report" do
    World.new()
    |> World.with_disruption(line: "Circle", status: "Minor Delays", description: "CIRCLE: Minor delays due to...")
    |> World.create()

    {:ok, message} = CommandRunner.execute(%Command{command: :disruptions})
    assert "CIRCLE: Minor delays due to...\n" == message
  end

  test "obtains current subscriptions for a given channel_id" do
    World.new()
    |> World.with_subscription(45, "channel_id", "Victoria")
    |> World.with_subscription(46, "channel_id", "London Overground")
    |> World.create()

    {:ok, message} =
      CommandRunner.execute(%Command{command: :subscriptions, channel_id: "channel_id"})

    assert "You are currently subscribed to: London Overground, Victoria" == message
  end

  test "formats a no-subscriptions message" do
    World.new()
    |> World.with_subscription(45, "channel_id", "Victoria")
    |> World.with_subscription(46, "channel_id", "London Overground")
    |> World.create()

    {:ok, message} =
      CommandRunner.execute(%Command{command: :subscriptions, channel_id: "wrong-channel_id"})

    assert "You are currently not subscribed to any line" == message
  end

  test "adds subscription to world" do
    World.new()
    |> World.create()

    {:ok, message} =
      CommandRunner.execute(%Command{
        command: :subscribe,
        params: ["victoria", "northern"],
        channel_id: "channel_id"
      })

    assert "Subscription saved!" == message
    # TODO - Verify that the subscription has been updated
  end

  test "remove subscription to world" do
    World.new()
    |> World.create()

    {:ok, message} =
      CommandRunner.execute(%Command{
        command: :unsubscribe,
        params: ["victoria", "northern"],
        channel_id: "channel_id"
      })

    assert "Subscription saved!" == message
    # TODO - Verify that the subscription has been updated
  end

  test "formats a friendly message upon inexistent command" do
    World.new()
    |> World.create()

    {:error, message} = CommandRunner.execute(%Command{command: ":)"})
    assert "The command you just tried doesn't exist!" == message
  end
end
