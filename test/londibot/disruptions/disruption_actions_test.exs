defmodule Londibot.DisruptionActionsTest do
  use ExUnit.Case, async: true

  alias Londibot.Repo
  alias Londibot.StatusChange
  alias Londibot.DisruptionActions

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Londibot.Repo)
  end

  describe "send_all_notifications/1" do
    test "send a notification per status change per subscription" do
      World.new()
      |> World.with_subscription("1", "123", "victoria")
      |> World.with_subscription("2", "456", "victoria")
      |> World.with_notifications(4)
      |> World.create()

      status_1 =
        StatusChange.new()
        |> StatusChange.with_line("Victoria")
        |> StatusChange.with_previous_status("Good Service")
        |> StatusChange.with_new_status("Severe Delays")
        |> StatusChange.with_description("Signal malfunction")

      status_2 =
        StatusChange.new()
        |> StatusChange.with_line("Victoria")
        |> StatusChange.with_previous_status("Severe Delays")
        |> StatusChange.with_new_status("Good Service")
        |> StatusChange.with_description("")

      [status_1, status_2]
      |> DisruptionActions.send_all_notifications()

      Mox.verify!(Londibot.NotifierMock)
    end
  end

  describe "insert_status_changes/1" do
    test "saves status changes to database, including timestamps" do
      StatusChange.new()
      |> StatusChange.with_line("Victoria")
      |> StatusChange.with_previous_status("Good Service")
      |> StatusChange.with_new_status("Severe Delays")
      |> StatusChange.with_description("Because reasons")
      |> List.wrap()
      |> DisruptionActions.insert_status_changes()

      [status_change | []] = Repo.all(StatusChange)

      assert "Victoria" == status_change.tfl_line
      assert "Good Service" == status_change.previous_status
      assert "Severe Delays" == status_change.new_status
      assert "Because reasons" == status_change.description
      assert nil != status_change.inserted_at
      assert "Etc/UTC" == status_change.inserted_at.time_zone
      assert nil != status_change.updated_at
      assert "Etc/UTC" == status_change.updated_at.time_zone
    end
  end
end
