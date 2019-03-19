defmodule Londibot.Controller do
  alias Londibot.TFL

  def report(statuses) do
    statuses
    |> Enum.map(fn {name, status, _ } -> ~s(#{name}: #{status}) end)
    |> Enum.join("\n")
  end

  def report_all do
    TFL.lines
    |> TFL.status
    |> report
  end
end
