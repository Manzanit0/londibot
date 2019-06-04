defmodule Londibot.Notification do
  defstruct [:message, :channel_id]
end

defmodule Londibot.NotifierBehaviour do
  @callback send(%Londibot.Notification{}) :: String.t()
end

defmodule Londibot.Notifier do
  require Logger

  alias Londibot.Notification

  @behaviour Londibot.NotifierBehaviour

  @slack_url "https://slack.com/api/chat.postMessage"
  @slack_token Application.get_env(:londibot, :slack_token)

  def send(%Notification{channel_id: channel_id, message: message}) do
    encoded_message = URI.encode(message)
    encoded_id = URI.encode(channel_id)

    "#{@slack_url}?token=#{@slack_token}&channel=#{encoded_id}&text=#{encoded_message}"
    # Empty body.
    |> HTTPoison.post!("")
  end
end
