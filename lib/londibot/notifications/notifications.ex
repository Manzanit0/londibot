defmodule Londibot.TelegramNotification do
  defstruct [:message, :channel_id]
end

defmodule Londibot.SlackNotification do
  defstruct [:message, :channel_id]
end

defmodule Londibot.NotificationFactory do
  alias Londibot.Subscription
  alias Londibot.SlackNotification
  alias Londibot.TelegramNotification
  alias Londibot.StatusChange

  def create(%Subscription{service: :slack} = s, message)
      when is_binary(message) do
    %SlackNotification{message: message, channel_id: s.channel_id}
  end

  def create(%Subscription{service: :telegram} = s, message)
      when is_binary(message) do
    %TelegramNotification{message: message, channel_id: s.channel_id}
  end

  def create(%Subscription{} = s, %StatusChange{} = change) do
    msg = message(change)
    create(s, msg)
  end

  defp message(%StatusChange{
         previous_status: previous,
         new_status: "Good Service",
         tfl_line: line
       }) do
    "✅ #{line} line status has changed from #{previous} to Good Service"
  end

  defp message(%StatusChange{
         previous_status: previous,
         new_status: new,
         tfl_line: line,
         description: desc
       })
       when new == "Closed" or new == "Not Running" do
    msg = "🚫 *#{line}* line status has changed from #{previous} to *#{new}*"
    if desc, do: msg <> " (#{desc})", else: msg
  end

  defp message(%StatusChange{
         previous_status: previous,
         new_status: new,
         description: desc,
         tfl_line: line
       }) do
    msg = "⚠️ *#{line}* line status has changed from #{previous} to *#{new}*"
    if desc, do: msg <> " (#{desc})", else: msg
  end
end
