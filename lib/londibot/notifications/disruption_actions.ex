defmodule Londibot.DisruptionActions do
  alias Londibot.TFL
  alias Londibot.Subscription
  alias Londibot.StatusChange
  alias Londibot.StatusBroker
  alias Londibot.NotificationFactory

  @notifier Application.get_env(:londibot, :notifier)
  @subscription_store Application.get_env(:londibot, :subscription_store)

  def send_all_notifications(), do: Enum.each(create_notifications(), &@notifier.send!/1)

  def create_notifications() do
    for %StatusChange{line: changed_line} = change <- StatusBroker.get_changes!(),
        subscription <- @subscription_store.all(),
        Subscription.subscribed?(subscription, changed_line) and not TFL.routinary?(change) do
      NotificationFactory.create(subscription, change)
    end
  end
end
