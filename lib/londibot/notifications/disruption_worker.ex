defmodule Londibot.DisruptionWorker do
  use GenServer

  require Logger

  alias Londibot.TFL
  alias Londibot.Subscription
  alias Londibot.StatusChange
  alias Londibot.StatusBroker
  alias Londibot.NotificationFactory

  @default_minutes 3

  @subscription_store Application.get_env(:londibot, :subscription_store)
  @notifier Application.get_env(:londibot, :notifier)

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
    send_all_notifications()

    if forever do
      schedule_work(minutes)
    end

    {:noreply, state}
  end

  defp send_all_notifications(), do: Enum.each(create_notifications(), &@notifier.send/1)

  def create_notifications() do
    for %StatusChange{line: changed_line} = change <- StatusBroker.get_changes(),
        subscription <- @subscription_store.all(),
        Subscription.subscribed?(subscription, changed_line) and not TFL.routinary?(change) do
      NotificationFactory.create(subscription, change)
    end
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
