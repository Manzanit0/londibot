defmodule Londibot.Commands.CommandTest do
  use ExUnit.Case

  alias Londibot.Commands.Command

  test "creats a full blown command!" do
    command = %Command{command: "hey", params: "ho", channel_id: "let's go!"}
    assert command == Command.new("hey", "ho", "let's go!")
  end

  test "adds channel_id" do
    command =
      Command.new("hey", "ho", "let's go!")
      |> Command.with_channel_id("new-id")

    assert %Command{command: "hey", params: "ho", channel_id: "new-id"} == command
  end
end
