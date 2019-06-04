defmodule Londibot.DisruptionWorker do
  use Task, restart: :permanent

  alias Londibot.Subscription
  alias Londibot.Notification

  @subscription_store Application.get_env(:londibot, :subscription_store)
  @tfl_service Application.get_env(:londibot, :tfl_service)
  @notifier Application.get_env(:londibot, :notifier)

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run([forever: forever] = arg) do
    Enum.each(disruption_notifications(), &@notifier.send/1)

    if forever do
      # TODO - a performance improvement could be
      # to use Process.send_after/4 + Genserver
      sleep(3)
      run(arg)
    end
  end

  def disruption_notifications do
    @tfl_service.lines()
    |> @tfl_service.status()
    |> @tfl_service.disruptions()
    |> create_notifications()
  end

  def create_notifications(disruptions) do
    for {disrupted_line, status, _} <- disruptions,
        %Subscription{channel_id: channel, tfl_lines: lines} <- @subscription_store.all(),
        subscribed?(lines, disrupted_line) do
      create_notification(disrupted_line, status, channel)
    end
  end

  defp subscribed?(subscribed_lines, disrupted_line) do
    Enum.any?(subscribed_lines, fn x ->
      String.downcase(x) == String.downcase(disrupted_line)
    end)
  end

  defp create_notification(disrupted_line, status, channel),
    do: %Notification{message: ~s(#{disrupted_line}: #{status}), channel_id: channel}

  defp sleep(minutes) do
    minutes
    |> :timer.minutes()
    |> :timer.sleep()
  end
end
