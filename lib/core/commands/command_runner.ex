defmodule Londibot.Commands.CommandRunner do
  alias Londibot.Commands.Command
  alias Londibot.Subscription

  @tfl_service Application.get_env(:londibot, :tfl_service)
  @subscription_store Application.get_env(:londibot, :subscription_store)

  def execute(%Command{command: "status"}) do
    @tfl_service.lines()
    |> @tfl_service.status()
    |> to_text(:status)
  end

  def execute(%Command{command: "disruptions"}) do
    @tfl_service.lines()
    |> @tfl_service.status()
    |> @tfl_service.disruptions()
    |> to_text(:disruptions)
  end

  def execute(%Command{command: "subscriptions", channel_id: channel_id}) do
    subscriptions =
      @subscription_store.all()
      |> Enum.filter(fn %Subscription{channel_id: c} -> c == channel_id end)
      |> Enum.map(fn x -> Map.get(x, :tfl_lines) end)
      |> List.flatten()
      |> Enum.join(", ")

    subscription_list_message(subscriptions)
  end

  def execute(%Command{command: "subscribe", params: p, channel_id: c}) do
    subscription = %Subscription{channel_id: c, tfl_lines: p}
    @subscription_store.save(subscription)

    subscription_saved_message()
  end

  def execute(_), do: {:error, "The command you just tried doesn't exist!"}

  defp subscription_saved_message, do: to_payload("Subscription saved!")

  defp subscription_list_message(""), do: to_payload("You are currently not subscribed to any line")
  defp subscription_list_message(subscriptions),do: to_payload("You are currently subscribed to: " <> subscriptions)

  defp to_payload(message) do
    %{text: message, response_type: "in_channel"}
    |> Poison.encode!()
  end

  defp to_text(statuses, mode) when is_list(statuses) do
    statuses
    |> Enum.map(fn status -> to_text(mode, status) end)
    |> Enum.join("\n")
  end

  defp to_text(:disruptions, {_, _, description}), do: ~s(#{description})
  defp to_text(:status, {name, status, _}), do: ~s(#{name}: #{status})
end
