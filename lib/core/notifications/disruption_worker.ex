defmodule Londibot.DisruptionWorker do
  use GenServer

  require Logger

  alias Londibot.Subscription
  alias Londibot.Notification

  @default_minutes 3

  @subscription_store Application.get_env(:londibot, :subscription_store)
  @tfl_service Application.get_env(:londibot, :tfl_service)
  @notifier Application.get_env(:londibot, :notifier)

  def start_link(args \\ []) do
    Logger.info("Starting DisruptionWorker")
    GenServer.start_link(__MODULE__, to_map(args))
  end

  defp to_map(args) do
    %{minutes: Keyword.get(args, :minutes, @default_minutes),
      forever: Keyword.get(args, :forever, true)}
  end

  def init(%{minutes: minutes} = state) do
    schedule_work(minutes)
    {:ok, state}
  end

  def handle_info(:work, %{minutes: minutes, forever: forever} = state) do
    send_all_notifications()

    if forever do
      schedule_work(minutes)
    end

    {:noreply, state}
  end

  defp send_all_notifications(), do: Enum.each(disruption_notifications(), &@notifier.send/1)

  def disruption_notifications do
    @tfl_service.lines()
    |> @tfl_service.status()
    |> @tfl_service.disruptions()
    |> create_notifications()
  end

  def create_notifications(disruptions) do
    for {disrupted_line, _, description} <- disruptions,
        %Subscription{channel_id: channel, tfl_lines: lines} <- @subscription_store.all(),
        subscribed?(lines, disrupted_line) do
      create_notification(description, channel)
    end
  end

  defp subscribed?(subscribed_lines, disrupted_line) do
    Enum.any?(subscribed_lines, fn x ->
      String.downcase(x) == String.downcase(disrupted_line)
    end)
  end

  defp create_notification(disruption_description, channel),
    do: %Notification{message: disruption_description, channel_id: channel}

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
