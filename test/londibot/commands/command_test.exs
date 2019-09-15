defmodule Londibot.Commands.CommandTest do
  use ExUnit.Case, async: true

  alias Londibot.Commands.Command

  test "creates a full blown command!" do
    command = %Command{command: "hey", params: "ho", channel_id: "let's go!"}
    assert command == Command.new("hey", "ho", "let's go!")
  end

  test "creates a command without channel_id" do
    command = %Command{command: "hey", params: "ho", channel_id: nil}
    assert command == Command.new("hey", "ho")
  end

  test "adds channel_id" do
    command =
      Command.new("hey", "ho", "let's go!")
      |> Command.with_channel_id("new-id")

    assert %Command{command: "hey", params: "ho", channel_id: "new-id"} == command
  end

  test "stringifies channel_ids" do
    command =
      Command.new("hey", "ho", "let's go!")
      |> Command.with_channel_id(12345)

    assert %Command{command: "hey", params: "ho", channel_id: "12345"} == command
  end
end
