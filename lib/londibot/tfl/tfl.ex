defmodule Londibot.TFL do
  alias Londibot.StatusChange

  @behaviour Londibot.TFLBehaviour

  @app_id Application.get_env(:londibot, :tfl_app_id)
  @app_key Application.get_env(:londibot, :tfl_app_key)

  def lines! do
    "https://api.tfl.gov.uk/Line/Mode/tube%2Cdlr%2Coverground%2Ctflrail"
    |> add_auth_params()
    |> HTTPoison.get!(recv_timeout: 50000)
    |> Map.get(:body)
    |> Poison.decode!()
    |> Enum.map(fn x -> x["id"] end)
  end

  def status!(lines) when is_list(lines) do
    lines
    |> Enum.join("%2C")
    |> status!
  end

  def status!(lines) when is_binary(lines) do
    "https://api.tfl.gov.uk/Line/#{lines}/Status"
    |> add_auth_params()
    |> HTTPoison.get!(recv_timeout: 50000)
    |> Map.get(:body)
    |> Poison.decode!()
    |> Enum.map(fn x -> parse_line(x) end)
  end

  # TODO there is an interesting endpoint ->
  # "https://api.tfl.gov.uk/Line/#{lines}/Disruption"
  def disruptions(status) do
    status
    |> Enum.filter(fn {_, status, _} -> status != "Good Service" end)
  end

  @doc """
  Checks if the `StatusChange` is a routinary/scheduled change, or if it's a proper
  unexpected change, i.e. nightly service closing.

  Returns `true` or `false.

  The known cases are:
  - Service Closed -> Good Service: daily service opening
  - description contains `Train service will resume later this morning`: nightly service closure

  ## Examples

      iex> service_on = %Londibot.StatusChange{previous_status: "Service Closed", new_status: "Good Service"}
      iex> Londibot.TFL.routinary?(service_on)
      true

      iex> abnormal_disruption = %Londibot.StatusChange{previous_status: "Severe Delays", new_status: "Good Service"}
      iex> Londibot.TFL.routinary?(abnormal_disruption)
      false

      iex> service_down = %Londibot.StatusChange{description: "Victoria line status has changed from Good Service to Service Closed (Victoria Line: Train service will resume later this morning. )"}
      iex> Londibot.TFL.routinary?(service_down)
      true
  """
  def routinary?(%StatusChange{previous_status: "Service Closed", new_status: "Good Service"}),
    do: true

  def routinary?(%StatusChange{description: desc}) when is_binary(desc) do
    String.contains?(desc, "Train service will resume later this morning")
  end

  def routinary?(_), do: false

  defp parse_line(%{"name" => name, "lineStatuses" => statuses}) do
    status = List.first(statuses)
    {name, status["statusSeverityDescription"], status["reason"]}
  end

  defp add_auth_params(url) do
    url <> "?app_id=#{@app_id}&app_key=#{@app_key}"
  end
end
