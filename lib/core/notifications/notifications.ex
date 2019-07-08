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
    message = "#{change.line} line status has changed from #{change.previous_status} to #{change.new_status} (#{change.description})"
    create(s, message)
  end
end
