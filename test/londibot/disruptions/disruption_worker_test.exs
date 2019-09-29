defmodule Londibot.DisruptionWorkerTest do
  use ExUnit.Case, async: false

  import Mox

  alias Londibot.DisruptionWorker
  alias Londibot.DisruptionWorkerTest.ActionMock, as: ActionMock

  setup :set_mox_global

  describe "handle_info/2" do
    test "The configured actions get executed every time handle_info is invoked" do
      World.new() |> World.create()

      ActionMock.start_link()

      actions = [&ActionMock.increment/1]
      DisruptionWorker.handle_info(:work, %{forever: false, minutes: nil, actions: actions})
      DisruptionWorker.handle_info(:work, %{forever: false, minutes: nil, actions: actions})

      assert 2 == ActionMock.value()
    end
  end

  describe "start_link/1" do
    test "actions passed through start_link are run upon handle_info" do
      World.new() |> World.create()

      ActionMock.start_link()

      actions = [&ActionMock.increment/1]
      DisruptionWorker.start_link(forever: false, minutes: 0.001, actions: actions)

      # I felt it was better to sleep the thread 100 ms to wait for it
      # to finish rather than not testing it.
      :timer.sleep(100)

      assert 1 == ActionMock.value()
    end
  end

  defmodule ActionMock do
    use Agent
    def start_link, do: Agent.start_link(fn -> 0 end, name: __MODULE__)
    def increment(_), do: Agent.update(__MODULE__, &(&1 + 1))
    def value, do: Agent.get(__MODULE__, & &1)
  end
end
