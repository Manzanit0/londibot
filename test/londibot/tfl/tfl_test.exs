defmodule Londibot.TFLTest do
  use ExUnit.Case, async: true
  doctest Londibot.TFL
  alias Londibot.TFL

  @tag :callout
  test "lists all the lines of tube, dlr, overground and tfl-rail" do
    assert length(TFL.lines!()) == 14
  end

  @tag :callout
  test "fetches the status of a single line" do
    [{name, status, description}] = TFL.status!("victoria")

    assert name == "Victoria"
    assert String.length(status) != 0
    if status == "Good Service", do: assert(description == nil)
  end

  @tag :callout
  test "fetches the status of multiple lines" do
    [{name, status, _}, {name2, status2, _}] = TFL.status!(["victoria", "circle"])

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

  test "upon no disruptions, filter every line" do
    status = [{"Victoria", "Good Service", "..."}, {"Circle", "Good Service", "..."}]

    disruptions = TFL.disruptions(status)

    assert Enum.count(disruptions) == 0
  end

  test "different routinary service shutdown messages" do
    routinary_change_messages = [
      "Victoria line status has changed from Good Service to Service Closed (Victoria Line: Service will resume later at 06.00h. )",
      "Victoria line status has changed from Good Service to Service Closed (Victoria Line: Train service resumes later this morning. )",
      "Jubilee Line: Train service will resume later this morning. ",
      "Waterloo and City Line: Train service resumes at 06.00 ",
      "Circle Line: Train service resumes later. ",
      "Hammersmith and City Line: Train service will resume later this morning. "
    ]

    for description <- routinary_change_messages do
      routinary_change =
        Londibot.StatusChange.new()
        |> Londibot.StatusChange.with_description(description)
        |> Londibot.TFL.routinary?()

      assert routinary_change == true
    end
  end
end
