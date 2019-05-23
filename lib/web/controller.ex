defmodule Londibot.Controller do
  @tfl_service Application.get_env(:londibot, :tfl_service)

  def report_all(mode) do
    statuses =
      @tfl_service.lines
      |> @tfl_service.status

    report(mode, statuses)
  end

  def report(mode, statuses) do
    filtered_statuses =
      case mode do
        :summary -> statuses
        :disruptions -> @tfl_service.disruptions(statuses)
      end

    to_text(mode, filtered_statuses)
  end

  defp to_text(mode, statuses) when is_list(statuses) do
    statuses
    |> Enum.map(fn status -> to_text(mode, status) end)
    |> Enum.join("\n")
  end
  defp to_text(:disruptions, {name, status, description}), do: ~s(#{description})
  defp to_text(:summary, {name, status, _}), do: ~s(#{name}: #{status})
end
