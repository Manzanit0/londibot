defmodule Londibot.Web.CommandParser do
  alias Londibot.Commands.Command

  def parse(text, id) do
    with {:ok, command, raw_params} <- parse_payload(text),
         {:ok, params} <- parse_params(raw_params) do
      Command.new(command, params, id)
    else
      _ -> {:error, "error parsing command"}
    end
  end

  defp parse_payload("subscribe" <> params), do: {:ok, "subscribe", params}
  defp parse_payload("unsubscribe" <> params), do: {:ok, "unsubscribe", params}
  defp parse_payload("subscriptions" <> params), do: {:ok, "subscriptions", params}
  defp parse_payload("status" <> params), do: {:ok, "status", params}
  defp parse_payload("disruptions" <> params), do: {:ok, "disruptions", params}
  defp parse_payload(_), do: {:error, "The command you just tried doesn't exist!"}

  defp parse_params(""), do: {:ok, []}
  defp parse_params(raw_params) do
    params =
      raw_params
      |> String.split(",")
      |> Enum.map(&String.trim/1)

    {:ok, params}
  end
end
