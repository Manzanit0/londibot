defimpl Londibot.Notifier, for: Londibot.TelegramNotification do
  require Logger

  alias Londibot.TelegramNotification, as: Notification

  @token Application.get_env(:londibot, :telegram_token)
  @endpoint "https://api.telegram.org/bot#{@token}/sendMessage"

  def send(%Notification{channel_id: channel_id, message: message}) do
    body =
      %{}
      |> Map.put(:chat_id, channel_id)
      |> Map.put(:text, message)
      |> Map.put(:parse_mode, "markdown")
      |> Poison.encode!()

    case HTTPoison.post(@endpoint, body, ["Content-Type": "Application/json"]) do
      {:error, error} -> handle_error(error)
      {:ok, response} -> handle_response(response)
    end
  end

  defp handle_error(%HTTPoison.Response{request: %{url: url}} = resp, err) when is_binary(err) do
    Logger.warn("\"#{err}\" thrown for request: #{url}")
    {:error, resp}
  end

  defp handle_error(%HTTPoison.Error{reason: reason} = err) do
    Logger.warn("telegram returned an error with reason #{inspect(reason)}")
    {:error, err}
  end

  defp handle_response(%HTTPoison.Response{body: body} = resp) do
    case Poison.decode!(body) do
      %{"ok" => false, "description" => err} -> handle_error(resp, err)
      _ -> {:ok, resp}
    end
  end
end
