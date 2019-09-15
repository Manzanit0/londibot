defmodule Londibot.DisruptionWorker do
  use GenServer

  alias Londibot.StatusBroker
  alias Londibot.DisruptionActions

  require Logger

  @default_minutes 3

  def default_params do
    [
      forever: true,
      minutes: @default_minutes,
      actions: [
        &DisruptionActions.send_all_notifications/1,
        &DisruptionActions.insert_status_changes/1
      ]
    ]
  end

  def start_link(args \\ []) do
    Logger.info("Starting DisruptionWorker")
    GenServer.start_link(__MODULE__, to_map(args))
  end

  defp to_map(args) do
    %{
      minutes: Keyword.get(args, :minutes, @default_minutes),
      forever: Keyword.get(args, :forever, true),
      actions: Keyword.get(args, :actions, [])
    }
  end

  def init(%{minutes: minutes} = state) do
    schedule_work(minutes)
    {:ok, state}
  end

  def handle_info(:work, %{minutes: minutes, forever: forever} = state) do
    changes = StatusBroker.get_non_routinary_changes!()
    Enum.each(state.actions, fn action -> action.(changes) end)

    if forever do
      schedule_work(minutes)
    end

    {:noreply, state}
  end

  defp schedule_work(minutes) do
    milliseconds = to_milliseconds(minutes)
    Process.send_after(self(), :work, milliseconds)
  end

  defp to_milliseconds(minutes) do
    minutes
    |> :timer.minutes()
    |> Kernel.trunc()
  end
end
