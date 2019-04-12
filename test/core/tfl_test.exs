defmodule Londibot.TFLTest do
  use ExUnit.Case, async: :true
  doctest Londibot.TFL
  alias Londibot.TFL

  @tag :callout
  test "lists all the lines of tube, dlr, overground and tfl-rail" do
    assert length(TFL.lines) == 14
  end

  @tag :callout
  test "fetches the status of a single line" do
    [{name, status, description}] = TFL.status("victoria")

    assert name == "Victoria"
    assert String.length(status) != 0
    if status == "Good Service", do: assert description == nil
  end

  @tag :callout
  test "fetches the status of multiple lines" do
    [{name, status, _}, {name2, status2, _}] = TFL.status(["victoria", "circle"])

    assert name == "Circle"
    assert name2 == "Victoria"
    assert String.length(status) != 0
    assert String.length(status2) != 0
  end

  test "find disruptions within a list of statuses" do
    status = [{"Victoria", "Good Service", "..."}, {"Circle", "Minor Delays", "..."}]

    disruptions = TFL.disruptions(status)
    {line, status, description} = Enum.fetch!(disruptions, 0)

    assert Enum.count(disruptions) == 1
    assert line == "Circle"
    assert status == "Minor Delays"
    assert description == "..."
  end
end
