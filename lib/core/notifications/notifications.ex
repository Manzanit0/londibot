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

  def create(%Subscription{service: :slack} = s, message) do
    %SlackNotification{message: message, channel_id: s.channel_id}
  end

  def create(%Subscription{service: :telegram} = s, message) do
    %TelegramNotification{message: message, channel_id: s.channel_id}
  end
end
