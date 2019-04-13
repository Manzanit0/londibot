defmodule Londibot.Controller do
  @tfl_service Application.get_env(:londibot, :tfl_service)

  def report({:disruptions, statuses}) do
    statuses
    |> @tfl_service.disruptions
    |> Enum.map(fn {name, status, description} -> ~s(#{name}: #{status} - #{description}) end)
    |> Enum.join("\n\n")
  end

  def report(statuses) do
    statuses
    |> Enum.map(fn {name, status, _ } -> ~s(#{name}: #{status}) end)
    |> Enum.join("\n")
  end

  def report_all(:disruptions) do
    disruptions =
      @tfl_service.lines
      |> @tfl_service.status
      |> @tfl_service.disruptions

    report({:disruptions, disruptions})
  end

  def report_all do
    @tfl_service.lines
    |> @tfl_service.status
    |> report
  end
end
