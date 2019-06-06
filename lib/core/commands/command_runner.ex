defmodule Londibot.Commands.CommandRunner do
  alias Londibot.Commands.Command

  @tfl_service Application.get_env(:londibot, :tfl_service)

  def execute(:status), do: execute(%Command{command: "status"})

  def execute(%Command{command: "status"}) do
    @tfl_service.lines()
    |> @tfl_service.status()
    |> to_text(:status)
  end

  def execute(:disruptions), do: execute(%Command{command: "disruptions"})

  def execute(%Command{command: "disruptions"}) do
    @tfl_service.lines()
    |> @tfl_service.status()
    |> @tfl_service.disruptions()
    |> to_text(:disruptions)
  end

  defp to_text(statuses, mode) when is_list(statuses) do
    statuses
    |> Enum.map(fn status -> to_text(mode, status) end)
    |> Enum.join("\n")
  end

  defp to_text(:disruptions, {_, _, description}), do: ~s(#{description})
  defp to_text(:status, {name, status, _}), do: ~s(#{name}: #{status})
end
