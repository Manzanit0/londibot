defmodule Londibot.TelegramNotification do
  defstruct [:message, :channel_id]
end

defmodule Londibot.SlackNotification do
  defstruct [:message, :channel_id]
end
