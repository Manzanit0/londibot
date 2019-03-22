defmodule Londibot.ControllerTest do
  use ExUnit.Case, async: true
  doctest Londibot.Controller

  alias Londibot.Controller

  import Mox

  @tfl_service Application.get_env(:londibot, :tfl_service)

  setup do
    lines_response = ["Victoria"]
    status_response = [{"Victoria", "Good Service", nil}]

    @tfl_service
    |> expect(:lines, fn -> lines_response end)
    |> expect(:status, fn _ -> status_response end)

    {:ok, tfl_service: @tfl_service}
  end

  test "mock works as expected" do
    assert @tfl_service.lines == ["Victoria"]
    assert @tfl_service.status("") == [{"Victoria", "Good Service", nil}]
  end

  test "fetches and formats all line statuses" do
    assert Controller.report_all == "Victoria: Good Service"
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
