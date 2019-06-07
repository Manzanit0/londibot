defmodule Londibot.Web.CommandParserTest do
  use ExUnit.Case, async: true

  alias Londibot.Web.CommandParser
  alias Londibot.Commands.Command

  test "parses command without params" do
    text = "status"

    cmd = %Command{
      command: "status",
      params: [],
      channel_id: "id"
    }

    assert cmd == CommandParser.parse(text, "id")
  end

  test "parses command with params" do
    text = "subscribe victoria, overground,northern"

    cmd = %Command{
      command: "subscribe",
      params: ["victoria", "overground", "northern"],
      channel_id: "id"
    }

    assert cmd == CommandParser.parse(text, "id")
  end

  test "detects invalid commands" do
    text = "nigiri victoria, overground, northern"
    result = {:error, "error parsing command"}

    assert result == CommandParser.parse(text, "id")
  end
end
