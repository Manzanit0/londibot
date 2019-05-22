defmodule Londibot.DisruptionWorker do
  alias Londibot.Subscription
  alias Londibot.Notification

  @subscription_store Application.get_env(:londibot, :subscription_store)
  @tfl_service Application.get_env(:londibot, :tfl_service)

  def disruption_notifications do
    @tfl_service.lines
    |> @tfl_service.status
    |> @tfl_service.disruptions
    |> create_notifications
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
end
