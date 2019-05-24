defmodule Londibot.Web.SubscriptionHandler do
  alias Londibot.Subscription
  alias Londibot.SubscriptionStore

  @subscription_store Application.get_env(:londibot, :subscription_store)

  def handle(conn = %Plug.Conn{body_params: bp}), do: handle(bp)
  def handle(body_params) do
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

  def subscription_saved_message do
    %{text: "Subscription saved!", response_type: "in_channel"}
    |> Poison.encode!()
  end
end
