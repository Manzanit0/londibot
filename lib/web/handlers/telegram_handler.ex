defmodule Londibot.Web.TelegramHandler do
  alias Londibot.Commands.CommandRunner
  alias Londibot.Web.CommandParser

  def handle(%Plug.Conn{body_params: bp}), do: handle(bp)

  # https://core.telegram.org/bots/api#update
  def handle(%{"message" => %{"from" => %{"id" => id}, "text" => text}}) do
    text
    |> remove_first_character()
    |> CommandParser.parse(id)
    |> CommandRunner.execute()
    |> to_response(id)
  end

  # Telegram commmands, unlike Slack, come with the leading slash.
  defp remove_first_character(str), do: String.slice(str, 1..-1)

  defp to_response({_, message}, id) do
    %{method: "sendMessage", chat_id: id, text: message, parse_mode: "markdown"}
    |> Poison.encode!()
  end
end
