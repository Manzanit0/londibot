defmodule Londibot.DisruptionWorkerTest do
  use ExUnit.Case

  import Mox

  alias Londibot.DisruptionWorker
  alias Londibot.StatusBroker

  setup :set_mox_global

  describe "handle_info/2" do
    test "sends a notification if a disruption happens" do
      World.new()
      |> World.with_subscription("1", "12345", "circle")
      |> World.with_disruption(
        line: "circle",
        status: "Broken",
        description: "oops",
        starts_after: 1,
        lasts_for: 20
      )
      |> World.with_notifications(1)
      |> World.create()

      StatusBroker.start_link()

      DisruptionWorker.handle_info(:work, %{forever: false, minutes: nil})

      Mox.verify!(Londibot.NotifierMock)
    end

    test "sends two notification if a disruption happens and then stops" do
      World.new()
      |> World.with_subscription("1", "12345", "circle")
      |> World.with_disruption(
        line: "circle",
        status: "Broken",
        description: "oops",
        starts_after: 1,
        lasts_for: 1
      )
      |> World.with_notifications(2)
      |> World.create()

      StatusBroker.start_link()

      DisruptionWorker.handle_info(:work, %{forever: false, minutes: nil})
      DisruptionWorker.handle_info(:work, %{forever: false, minutes: nil})

      Mox.verify!(Londibot.NotifierMock)
    end
  end

  describe "start_link/0" do
    # This test is just like "sends a notification if a disruption happens"
    # but with DisruptionWorker.start_link/0 as the entry point.
    test "starts the worker and sends notifications on disruptions" do
      World.new()
      |> World.with_subscription("1", "12345", "circle")
      |> World.with_disruption(
        line: "circle",
        status: "Broken",
        description: "oops",
        starts_after: 1,
        lasts_for: 20
      )
      |> World.with_notifications(1)
      |> World.create()

      StatusBroker.start_link()

      DisruptionWorker.start_link(forever: false, minutes: 0.001)

      # I felt it was better to sleep the thread 100 ms to wait for it
      # to finish rather than not testing it.
      :timer.sleep(100)

      Mox.verify!(Londibot.NotifierMock)
    end
  end
end
