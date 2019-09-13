defmodule Londibot.DisruptionActionsTest do
  use ExUnit.Case

  alias Londibot.StatusChange
  alias Londibot.DisruptionActions

  describe "send_all_notifications/1" do
    test "send a notification per status change per subscription" do
      World.new()
      |> World.with_subscription("1", "123", "victoria")
      |> World.with_subscription("2", "456", "victoria")
      |> World.with_notifications(4)
      |> World.create()

      status_changes = [
        %StatusChange{
          line: "victoria",
          previous_status: "Good Service",
          new_status: "Severe Delays",
          description: ""
        },
        %StatusChange{
          line: "victoria",
          previous_status: "Severe Delays",
          new_status: "Good Service",
          description: ""
        }
      ]

      :ok = DisruptionActions.send_all_notifications(status_changes)

      Mox.verify!(Londibot.NotifierMock)
    end
  end
end
