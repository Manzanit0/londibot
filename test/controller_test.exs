defmodule Londibot.ControllerTest do
  use ExUnit.Case, async: true
  doctest Londibot.Controller

  alias Londibot.Controller

  @tag :callout
  test "Formats all line statuses" do
    result = Controller.report_all
    assert length(String.split(result, "\n")) == 14
  end

  test "formats line statuses as a report" do
    statuses = [
      {"Victoria", "Good Service", nil},
      {"Circle", "Minor Delays", "Due to blablabla"}
    ]

    result = Controller.report(statuses)

    assert result ==
    """
    Victoria: Good Service
    Circle: Minor Delays\
    """
  end
end
