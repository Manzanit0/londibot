defmodule Londibot.DisruptionWorker do
  use GenServer

  alias Londibot.DisruptionActions

  require Logger

  @default_minutes 3

  def start_link(args \\ []) do
    Logger.info("Starting DisruptionWorker")
    GenServer.start_link(__MODULE__, to_map(args))
  end

  defp to_map(args) do
    %{
      minutes: Keyword.get(args, :minutes, @default_minutes),
      forever: Keyword.get(args, :forever, true)
    }
  end

  def init(%{minutes: minutes} = state) do
    schedule_work(minutes)
    {:ok, state}
  end

  def handle_info(:work, %{minutes: minutes, forever: forever} = state) do
    DisruptionActions.send_all_notifications()

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
