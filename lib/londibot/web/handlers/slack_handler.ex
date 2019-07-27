defmodule Londibot.Web.Handlers.SlackHandler do
  alias Londibot.Commands.Command
  alias Londibot.Commands.CommandRunner
  alias Londibot.Web.CommandParser

  def handle(%Plug.Conn{body_params: bp}), do: handle(bp)

  # Read: https://api.slack.com/slash-commands
  # Slack will occasionally send your command's request URL a simple POST
  # request to verify the server's SSL certificate. These requests will
  # include a parameter ssl_check set to 1 and a token parameter.
  def handle(%{"ssl_check" => _, "token" => _}), do: "Received!"

  # TODO Potentially wrap execute in a task? and return a custom response?
  def handle(%{"channel_id" => id, "text" => text}) do
    with %Command{} = command <- CommandParser.parse(text) do
      command
      |> Command.with_channel_id(id)
      |> Command.with_service(:slack)
      |> CommandRunner.execute()
      |> to_response()
    else
      {:error, message} -> to_response({:error, message})
    end
  end

  # If the user triggers an error, keep it silent and give only him the feedback.
  defp to_response({:error, message}),
    do: Poison.encode!(%{text: message})

  defp to_response({:ok, message}),
    do: Poison.encode!(%{text: message, response_type: "in_channel"})
end
