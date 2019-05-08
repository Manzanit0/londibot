defmodule Londibot.NotifierBehaviour do
  @callback send(String.t, String.t) :: String.t
end

defmodule Londibot.Notifier do
  @behaviour Londibot.NotifierBehaviour

  @slack_url "https://slack.com/api/chat.postMessage"
  @slack_token Application.get_env(:londibot, :slack_token)

 def send(message, channel_id) do
   encoded_message = URI.encode(message)
   encoded_id = URI.encode(channel_id)

   "#{@slack_url}?token=#{@slack_token}&channel=#{encoded_id}&text=#{encoded_message}"
   |> HTTPoison.post!("") # Empty body.
 end
end

defmodule Londibot.Notification do
  defstruct [:message, :channel_id]
end
