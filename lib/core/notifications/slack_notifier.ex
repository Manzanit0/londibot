defimpl Londibot.Notifier, for: Londibot.SlackNotification do
  require Logger

  alias Londibot.SlackNotification, as: Notification

  @slack_url "https://slack.com/api/chat.postMessage"
  @slack_token Application.get_env(:londibot, :slack_token)

  def send(%Notification{channel_id: channel_id, message: message}) do
    encoded_message = URI.encode(message)
    encoded_id = URI.encode(channel_id)

    url = "#{@slack_url}?token=#{@slack_token}&channel=#{encoded_id}&text=#{encoded_message}"

    # Empty body -> message is in the URL
    case HTTPoison.post(url, "") do
      {:error, error} -> handle_error(error)
      {:ok, response} -> handle_response(response)
    end
  end

  # Slack API only returns an error (4xx, 5xx...) upon an actual API error. Otherwise,
  # it returns the errors in the body with a 200. That's why two different error handlers
  # are needed.
  defp handle_error(%HTTPoison.Response{request: %{url: url}} = resp, err) when is_binary(err) do
    Logger.warn("\"#{err}\" thrown for request: #{url}")
    {:error, resp}
  end

  defp handle_error(%HTTPoison.Error{reason: reason} = err) do
    Logger.warn("slack returned an error with reason #{inspect(reason)}")
    {:error, err}
  end

  defp handle_response(%HTTPoison.Response{body: body} = resp) do
    case Poison.decode!(body) do
      %{"ok" => false, "error" => err} -> handle_error(resp, err)
      _ -> {:ok, resp}
    end
  end
end
