defmodule Londibot.Web.SlackHandler do
  alias Londibot.Commands.Command
  alias Londibot.Commands.CommandRunner

  def handle(%Plug.Conn{body_params: bp}), do: handle(bp)

  # Read: https://api.slack.com/slash-commands
  # Slack will occasionally send your command's request URL a simple POST
  # request to verify the server's SSL certificate. These requests will
  # include a parameter ssl_check set to 1 and a token parameter.
  def handle(%{"ssl_check" => _, "token" => _}), do: "Received!"

  def handle(%{"channel_id" => id, "text" => text}) do
    with {:ok, command, raw_params} <- process_payload(text),
         {:ok, params} <- process_params(raw_params) do
      Command.new(command, params, id)
      # TODO Potentially wrap execute in a task? and return a custom response?
      |> CommandRunner.execute()
    else
      {:error, err} -> {:error, err}
    end
  end

  # TODO - use atoms
  defp process_payload("subscribe" <> params), do: {:ok, "subscribe", params}
  defp process_payload("unsubscribe" <> params), do: {:ok, "unsubscribe", params}
  defp process_payload("subscriptions" <> params), do: {:ok, "subscriptions", params}
  defp process_payload("status" <> params), do: {:ok, "status", params}
  defp process_payload("disruptions" <> params), do: {:ok, "disruptions", params}
  defp process_payload(_), do: {:error, "The command you just tried doesn't exist!"}

  defp process_params(raw_params), do: {:ok, String.split(raw_params, ", ")}
end
