defmodule Londibot.ControllerTest do
  use ExUnit.Case, async: true
  doctest Londibot.Controller

  alias Londibot.Controller

  import Mox

  test "fetches and formats all line statuses" do
    setup_tfl_mock()

    assert Controller.report_all(:summary) == "Victoria: Good Service"
  end

  test "formats line statuses as a report" do
    statuses = [
      {"Victoria", "Good Service", nil},
      {"Circle", "Minor Delays", "Due to blablabla"}
    ]

    result = Controller.report(:summary, statuses)

    assert result ==
    """
    Victoria: Good Service
    Circle: Minor Delays\
    """
  end

  test "formats disruptions as a report" do
    setup_tfl_mock()
    statuses = [
      {"Victoria", "Good Service", nil},
      {"Circle", "Minor Delays", "Due to blablabla"}
    ]

    result = Controller.report(:disruptions, statuses)

    assert result ==
      """
    Circle: Minor Delays - Due to blablabla\
    """
  end

  defp setup_tfl_mock do
    tfl_service = Application.get_env(:londibot, :tfl_service)

    tfl_service
    |> expect(:lines, fn -> ["Victoria"] end)
    |> expect(:status, fn _ -> [{"Victoria", "Good Service", nil}] end)
    |> expect(:disruptions, fn _ -> [{"Circle", "Minor Delays", "Due to blablabla"}] end)
  end
end
