defimpl Londibot.Notifier, for: Londibot.TelegramNotification do
  require Logger

  alias Londibot.TelegramNotification, as: Notification
  alias HTTPoison.Response
  alias HTTPoison.Error

  @token Application.get_env(:londibot, :telegram_token)
  @endpoint "https://api.telegram.org/bot#{@token}/sendMessage"

  def send!(%Notification{channel_id: id, message: message}) do
    headers = ["Content-Type": "Application/json"]
    body = Poison.encode!(%{chat_id: id, text: message, parse_mode: "markdown"})

    case HTTPoison.post(@endpoint, body, headers) do
      {:error, error} -> handle_error(error)
      {:ok, response} -> handle_response!(response)
    end
  end

  defp handle_response!(%Response{body: body} = resp) do
    case Poison.decode!(body) do
      %{"ok" => false, "description" => err} -> handle_error(resp, err)
      _ -> {:ok, resp}
    end
  end

  defp handle_error(%Response{request: %{url: url}} = resp, err) when is_binary(err) do
    Logger.warn("\"#{err}\" thrown for request: #{url}")
    {:error, resp}
  end

  defp handle_error(%Error{reason: reason} = err) do
    Logger.warn("telegram returned an error with reason #{inspect(reason)}")
    {:error, err}
  end
end
