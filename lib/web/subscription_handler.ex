defmodule Londibot.Web.SubscriptionHandler do
  alias Londibot.Subscription

  @subscription_store Application.get_env(:londibot, :subscription_store)

  def handle(%Plug.Conn{body_params: bp, query_params: qp}), do: handle(bp, qp)
  def handle(bp = %{"channel_id" => _, "text" => _}, %{"q" => "new"}), do: process_subscription(bp)
  def handle(%{"channel_id" => c, "text" => _}, %{"q" => "all"}), do: get_subscriptions(c)
  def handle(%{}, %{}), do: reprompt_message()

  defp process_subscription(body_params) do
    body_params
    |> to_subscription()
    |> @subscription_store.save()

    subscription_saved_message()
  end

  defp to_subscription(%{"channel_id" => c, "text" => t}) do
    lines = parse_lines(t)
    %Subscription{channel_id: c, tfl_lines: lines}
  end

  defp parse_lines(lines), do: String.split(lines, ",")

  def get_subscriptions(channel_id) do
    subscriptions =
      @subscription_store.all()
      |> Enum.filter(fn %Subscription{channel_id: c} -> c == channel_id end)
      |> Enum.map(fn x -> Map.get(x, :tfl_lines) end)
      |> List.flatten()
      |> Enum.join(", ")

    subscription_list_message(subscriptions)
  end

  def subscription_saved_message, do: to_payload("Subscription saved!")

  defp reprompt_message, do: to_payload("error: empty request")

  defp subscription_list_message(""), do: to_payload("You are currently not subscribed to any line")
  defp subscription_list_message(subscriptions),do: to_payload("You are currently subscribed to: " <> subscriptions)

  defp to_payload(message) do
    %{text: message, response_type: "in_channel"}
    |> Poison.encode!()
  end
end
