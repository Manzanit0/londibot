defmodule Londibot.Controller do
  @tfl_service Application.get_env(:londibot, :tfl_service)

  def report(statuses) do
    statuses
    |> Enum.map(fn {name, status, _ } -> ~s(#{name}: #{status}) end)
    |> Enum.join("\n")
  end

  def report_all do
    @tfl_service.lines
    |> @tfl_service.status
    |> report
  end
end
