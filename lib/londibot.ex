defmodule Londibot do
  def tfl_lines do
    "https://api.tfl.gov.uk/Line/Mode/tube%2Cdlr%2Coverground%2Ctflrail"
    |> HTTPoison.get!
    |> Map.get(:body)
    |> Poison.decode!
    |> Enum.map(fn x -> x["id"] end)
  end

  def tfl_status(lines) when is_list(lines) do
    lines
    |> Enum.join("%2C")
    |> tfl_status
  end

  def tfl_status(lines) when is_binary(lines) do
    "https://api.tfl.gov.uk/Line/#{lines}/Status?detail=true"
    |> HTTPoison.get!
    |> Map.get(:body)
    |> Poison.decode!
    |> Enum.map(fn x -> parse_line(x) end)
  end

  defp parse_line(%{"name" => name, "lineStatuses" => statuses}) do
    status = List.first(statuses)
    {name, status["statusSeverityDescription"], status["reason"]}
  end
end
