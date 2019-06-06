defmodule Londibot.Commands.CommandRunnerTest do
  use ExUnit.Case, async: true

  alias Londibot.Commands.CommandRunner
  alias Londibot.Commands.Command

  test "formats line statuses as a report" do
    World.new
    |> World.with_disruption("Circle", "Minor Delays", "...")
    |> World.create()

    result = CommandRunner.execute(%Command{command: "status"})

    # World prints returns the information for all the lines.
    # The interesting thing to test here is that CommandRunner returns
    # a text with some of the info.
    assert String.contains?(result, "Circle: Minor Delays\n")
    assert String.contains?(result, "victoria: Good Service\n")
  end

  test "formats disruptions as a report" do
    World.new
    |> World.with_disruption("Circle", "Minor Delays", "CIRCLE: Minor delays due to...")
    |> World.create()

    assert "CIRCLE: Minor delays due to..." == CommandRunner.execute(%Command{command: "disruptions"})
  end

  test "obtains current subscriptions for a given channel_id" do
    World.new
    |> World.with_subscription(45, "channel_id", "Victoria")
    |> World.with_subscription(46, "channel_id", "London Overground")
    |> World.create()

    expected = "{\"text\":\"You are currently subscribed to: London Overground, Victoria\",\"response_type\":\"in_channel\"}"
    assert expected == CommandRunner.execute(%Command{command: "subscriptions", channel_id: "channel_id"})
  end

  test "formats a no-subscriptions message" do
    World.new
    |> World.with_subscription(45, "channel_id", "Victoria")
    |> World.with_subscription(46, "channel_id", "London Overground")
    |> World.create()

    expected = "{\"text\":\"You are currently not subscribed to any line\",\"response_type\":\"in_channel\"}"
    assert expected == CommandRunner.execute(%Command{command: "subscriptions", channel_id: "wrong-channel_id"})
  end

  test "adds subscription to world" do
    World.new
    |> World.create()

    expected = "{\"text\":\"Subscription saved!\",\"response_type\":\"in_channel\"}"
    assert expected == CommandRunner.execute(%Command{command: "subscribe", params: "victoria, northern", channel_id: "channel_id"})
  end


  test "formats a friendly message upon inexistent command" do
    World.new
    |> World.create()

    # TODO - this isn't consistent with the rest of the return types.
    expected = {:error, "The command you just tried doesn't exist!"}
    assert expected == CommandRunner.execute(%Command{command: ":)"})
  end
end
