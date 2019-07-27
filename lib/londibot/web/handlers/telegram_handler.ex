defmodule Londibot.Web.TelegramHandler do
  require Logger

  alias Londibot.Commands.Command
  alias Londibot.Commands.CommandRunner
  alias Londibot.Web.CommandParser

  def handle(%Plug.Conn{body_params: bp}), do: handle(bp)

  # https://core.telegram.org/bots/api#update
  def handle(%{"message" => %{"from" => %{"id" => id}, "text" => raw_text}}) do
    with text <- remove_first_character(raw_text),
         %Command{} = command <- CommandParser.parse(text) do
      command
      |> Command.with_channel_id(id)
      |> Command.with_service(:telegram)
      |> CommandRunner.execute()
      |> to_response(id)
    else
      {:error, message} -> to_response({:error, message}, id)
    end
  end

  # Unless it's a text message, return empty body, a.k.a, ignore the message
  def handle(unknown_message) do
    Util.track_error(unknown_message,
      severity: :warn,
      message: "Unknown message received via Telegram"
    )

    ""
  end

  # Telegram commmands, unlike Slack, come with the leading slash.
  defp remove_first_character(str), do: String.slice(str, 1..-1)

  defp to_response({_, message}, id) do
    %{method: "sendMessage", chat_id: id, text: message, parse_mode: "markdown"}
    |> Poison.encode!()
  end
end
