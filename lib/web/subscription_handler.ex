defmodule Londibot.Web.SubscriptionHandler do
  alias Londibot.Subscription
  alias Londibot.SubscriptionStore

  @subscription_store Application.get_env(:londibot, :subscription_store)

  def handle(conn = %Plug.Conn{body_params: bp, query_params: qp}), do: handle(bp, qp)
  def handle(bp = %{"channel_id" => c, "text" => t}, %{"q" => "new"}), do: process_subscription(bp)
  def handle(%{}, %{}), do: reprompt_message()

  def process_subscription(body_params) do
    body_params
    |> to_subscription()
    |> @subscription_store.save()

    subscription_saved_message()
  end

  def parse_lines(lines), do: String.split(lines, ",")

  def to_subscription(%{"channel_id" => c, "text" => t}) do
    lines = parse_lines(t)
    %Subscription{channel_id: c, tfl_lines: lines}
  end

  def subscription_saved_message, do: to_payload("Subscription saved!")

  def reprompt_message, do: to_payload("error: empty request")

  defp to_payload(message) do
    %{text: message, response_type: "in_channel"}
    |> Poison.encode!()
  end
end
