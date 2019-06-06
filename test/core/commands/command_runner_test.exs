defmodule Londibot.Commands.CommandRunnerTest do
  use ExUnit.Case, async: true

  alias Londibot.Commands.CommandRunner

  test "formats line statuses as a report" do
    World.new
    |> World.with_disruption("Circle", "Minor Delays", "...")
    |> World.create()

    result = CommandRunner.execute(:status)

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

    assert "CIRCLE: Minor delays due to..." == CommandRunner.execute(:disruptions)
  end
end
