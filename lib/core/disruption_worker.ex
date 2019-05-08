defmodule Londibot.DisruptionWorker do
  alias Londibot.Subscription
  alias Londibot.Notification

  @subscription_store Application.get_env(:londibot, :subscription_store)

  def create_notifications(disruptions) do
    subscriptions = @subscription_store.all()

    for {line, status, _} <- disruptions,
      %Subscription{channel_id: channel, tfl_lines: lines} <- subscriptions,
      Enum.any?(lines, fn x -> x == line end),
      do: %Notification{message: ~s(#{line}: #{status}), channel_id: channel}
  end
end
