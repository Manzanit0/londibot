defmodule Londibot.TFLTest do
  use ExUnit.Case
  doctest Londibot.TFL
  alias Londibot.TFL

  test "lists all the lines of tube, dlr, overground and tfl-rail" do
    assert length(TFL.lines) == 14
  end

  test "fetches the status of a single line" do
    [{name, status, description}] = TFL.status("victoria")

    assert name == "Victoria"
    assert String.length(status) != 0
    if status == "Good Service", do: assert description == nil
  end

  test "fetches the status of multiple lines" do
    [{name, status, _}, {name2, status2, _}] = TFL.status(["victoria", "circle"])

    assert name == "Circle"
    assert name2 == "Victoria"
    assert String.length(status) != 0
    assert String.length(status2) != 0
  end
end
