defmodule Londibot.Web.TelegramHandler do
  alias Londibot.Commands.Command
  alias Londibot.Commands.CommandRunner

  def handle(%Plug.Conn{body_params: bp}) do
    handle(bp)
  end

  # https://core.telegram.org/bots/api#update
  def handle(%{"message" => %{"from" => %{"id" => id}, "text" => text}}) do
    with {:ok, command, raw_params} <- process_payload(text),
         {:ok, params} <- process_params(raw_params) do
      Command.new(command, params, id)
      |> CommandRunner.execute()
      |> to_response(id)
    else
      {:error, err} -> to_response({:error, err}, id)
    end
  end

  defp to_response({:error, message}, id),
    do: Poison.encode!(%{method: "sendMessage", chat_id: id, text: message, parse_mode: "markdown"})

  defp to_response({:ok, message}, id),
    do: Poison.encode!(%{method: "sendMessage", chat_id: id, text: message, parse_mode: "markdown"})

  defp process_payload("/subscribe" <> params), do: {:ok, "subscribe", params}
  defp process_payload("/unsubscribe" <> params), do: {:ok, "unsubscribe", params}
  defp process_payload("/subscriptions" <> params), do: {:ok, "subscriptions", params}
  defp process_payload("/status" <> params), do: {:ok, "status", params}
  defp process_payload("/disruptions" <> params), do: {:ok, "disruptions", params}
  defp process_payload(_), do: {:error, "The command you just tried doesn't exist!"}

  defp process_params(raw_params), do: {:ok, String.split(raw_params, ", ")}
end
