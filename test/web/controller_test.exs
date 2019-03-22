defmodule Londibot.ControllerTest do
  use ExUnit.Case, async: true
  doctest Londibot.Controller

  alias Londibot.Controller

  import Mox

  test "fetches and formats all line statuses" do
    setup_tfl_mock()

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

  defp setup_tfl_mock do
    tfl_service = Application.get_env(:londibot, :tfl_service)

    tfl_service
    |> expect(:lines, fn -> ["Victoria"] end)
    |> expect(:status, fn _ -> [{"Victoria", "Good Service", nil}] end)
  end
end
