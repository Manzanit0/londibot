defmodule Londibot.TFLBehaviour do
  @callback lines() :: [String.t]
  @callback status(list) :: String.t
  @callback status(String.t) :: String.t
  @callback disruptions(list) :: list
end

defmodule Londibot.TFL do
  @behaviour Londibot.TFLBehaviour

  def lines do
    "https://api.tfl.gov.uk/Line/Mode/tube%2Cdlr%2Coverground%2Ctflrail"
    |> HTTPoison.get!(recv_timeout: 50000)
    |> Map.get(:body)
    |> Poison.decode!
    |> Enum.map(fn x -> x["id"] end)
  end

  def status(lines) when is_list(lines) do
    lines
    |> Enum.join("%2C")
    |> status
  end

  def status(lines) when is_binary(lines) do
    "https://api.tfl.gov.uk/Line/#{lines}/Status?detail=true"
    |> HTTPoison.get!
    |> Map.get(:body)
    |> Poison.decode!
    |> Enum.map(fn x -> parse_line(x) end)
  end

  # TODO there is an interesting endpoint ->
  # "https://api.tfl.gov.uk/Line/#{lines}/Disruption"
  def disruptions(status) do
    status
    |> Enum.filter(fn {_, status, _} -> status != "Good Service" end)
  end

  defp parse_line(%{"name" => name, "lineStatuses" => statuses}) do
    status = List.first(statuses)
    {name, status["statusSeverityDescription"], status["reason"]}
  end
end
