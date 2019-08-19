defimpl Londibot.Notifier, for: Londibot.SlackNotification do
  require Logger

  alias Londibot.SlackNotification, as: Notification
  alias HTTPoison.Response
  alias HTTPoison.Error

  @endpoint "https://slack.com/api/chat.postMessage"
  @token Application.get_env(:londibot, :slack_token)

  def send!(%Notification{channel_id: channel_id, message: message}) do
    encoded_message = URI.encode(message)
    encoded_id = URI.encode(channel_id)

    url = "#{@endpoint}?token=#{@token}&channel=#{encoded_id}&text=#{encoded_message}"

    # Empty body -> message is in the URL
    case HTTPoison.post(url, "") do
      {:error, error} -> handle_error(error)
      {:ok, response} -> handle_response!(response)
    end
  end

  defp handle_response!(%Response{body: body} = resp) do
    case Poison.decode!(body) do
      %{"ok" => false, "error" => err} -> handle_error(resp, err)
      _ -> {:ok, resp}
    end
  end

  defp handle_error(%Response{request: %{url: url}} = resp, err) when is_binary(err) do
    Logger.warn("\"#{err}\" thrown for request: #{url}")
    {:error, resp}
  end

  defp handle_error(%Error{reason: reason} = err) do
    Logger.warn("slack returned an error with reason #{inspect(reason)}")
    {:error, err}
  end
end
