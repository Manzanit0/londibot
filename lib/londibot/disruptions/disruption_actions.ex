defmodule Londibot.DisruptionActions do
  alias Ecto.Changeset
  alias Londibot.Repo
  alias Londibot.Subscription
  alias Londibot.StatusChange
  alias Londibot.NotificationFactory

  @notifier Application.get_env(:londibot, :notifier)
  @subscription_store Application.get_env(:londibot, :subscription_store)

  def insert_status_changes(status_changes) do
    status_changes
    |> Enum.map(&to_changeset/1)
    |> Enum.map(&Repo.insert/1)
  end

  defp to_changeset(status_change, params \\ %{}) do
    status_change
    |> Changeset.cast(params, [
      :line,
      :previous_status,
      :new_status,
      :description
    ])
    |> Changeset.validate_required([
      :line,
      :previous_status,
      :new_status,
      :description
    ])
  end

  def send_all_notifications(status_changes) do
    status_changes
    |> collect_subscriptions()
    |> create_notifications()
    |> send_notifications()
  end

  defp collect_subscriptions(status_changes) do
    for %StatusChange{line: changed_line} = change <- status_changes,
        subscription <- @subscription_store.all(),
        Subscription.subscribed?(subscription, changed_line) do
      {subscription, change}
    end
  end

  defp create_notifications(subscription_changes)
       when is_list(subscription_changes) do
    Enum.map(subscription_changes, &create_notification/1)
  end

  defp create_notification({subcription, change}) do
    NotificationFactory.create(subcription, change)
  end

  defp send_notifications(notifications) do
    Enum.each(notifications, &@notifier.send!/1)
  end
end
