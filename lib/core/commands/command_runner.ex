defmodule Londibot.Commands.CommandRunner do
  alias Londibot.Commands.Command
  alias Londibot.Subscription

  @tfl_service Application.get_env(:londibot, :tfl_service)
  @subscription_store Application.get_env(:londibot, :subscription_store)

  def execute(%Command{command: :status}) do
    message =
      @tfl_service.lines()
      |> @tfl_service.status()
      |> to_status_message()

    {:ok, message}
  end

  def execute(%Command{command: :disruptions}) do
    message =
      @tfl_service.lines()
      |> @tfl_service.status()
      |> @tfl_service.disruptions()
      |> to_disruption_message()

    {:ok, message}
  end

  def execute(%Command{command: :subscriptions, channel_id: channel_id}) do
    message =
      @subscription_store.all()
      |> Enum.filter(fn %Subscription{channel_id: c} -> c == channel_id end)
      |> to_subscriptions_message()

    {:ok, message}
  end

  def execute(%Command{command: :subscribe, params: p, channel_id: c, service: s}) do
    subscription = %Subscription{channel_id: c, tfl_lines: p, service: s}
    @subscription_store.save(subscription)

    {:ok, "Subscription saved!"}
  end

  def execute(_), do: {:error, "The command you just tried doesn't exist!"}

  defp to_subscriptions_message(subscriptions) do
    message =
      subscriptions
      |> Enum.map(fn x -> Map.get(x, :tfl_lines) end)
      |> List.flatten()
      |> Enum.join(", ")

    if String.length(message) > 0 do
      "You are currently subscribed to: " <> message
    else
      "You are currently not subscribed to any line"
    end
  end

  defp to_disruption_message(disruptions) do
    disruptions
    |> Enum.map(fn {_, _, description} -> ~s(#{description}\n) end)
    |> Enum.join("\n")
  end

  defp to_status_message(statuses) do
    statuses
    |> Enum.map(&status/1)
    |> Enum.join("\n")
  end

  defp status({name, "Good Service", _}), do: "✅ #{name}: Good Service"
  defp status({name, "Closed", _}), do: "🚫 #{name}: Closed"
  defp status({name, "Service Closed", _}), do: "🚫 #{name}: Service Closed"
  defp status({name, "Not Running", _}), do: "🚫 #{name}: Not Running"
  defp status({name, status, _}), do: "⚠️ #{name}: #{status}"
end
