defmodule Londibot.DisruptionWorker do
  use GenServer

  require Logger

  alias Londibot.Subscription
  alias Londibot.Notification

  @default_minutes 3

  @subscription_store Application.get_env(:londibot, :subscription_store)
  @tfl_service Application.get_env(:londibot, :tfl_service)
  @notifier Application.get_env(:londibot, :notifier)

  def start_link(arg \\ []) do
    Logger.info("Starting DisruptionWorker")
    GenServer.start_link(__MODULE__, arg)
  end

  def init(state) do
    state
    |> Keyword.get(:minutes, @default_minutes)
    |> schedule_work()

    {:ok, state}
  end

  def handle_info(:work, state) do
    Enum.each(disruption_notifications(), &@notifier.send/1)

    if Keyword.get(state, :forever) do
      minutes = Keyword.get(state, :minutes, @default_minutes)
      schedule_work(minutes)
    end

    {:noreply, state}
  end

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
    milliseconds =
      minutes
      |> :timer.minutes()
      |> Kernel.trunc()

    Process.send_after(self(), :work, milliseconds)
  end
end
