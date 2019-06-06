defmodule Londibot.Commands.CommandTest do
  use ExUnit.Case

  alias Londibot.Commands.Command

  test "creats a full blown command!" do
    command = %Command{command: "hey", params: "ho", channel_id: "let's go!"}
    assert command == Command.new("hey", "ho", "let's go!")
  end
end
