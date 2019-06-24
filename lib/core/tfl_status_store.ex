defmodule Londibot.TFLLine do
  defstruct [:name, :status, :status_verbose, :last_disruption_on, :last_updated_on]
end

defmodule Londibot.TFLStatusStore do
  use Agent

  require Logger

  alias Londibot.TFLLine

  @behaviour Londibot.StoreBehaviour

  @tfl_service Application.get_env(:londibot, :tfl_service)

  def start_link, do: initial_status() |> start_link()

  def start_link(status) do
    Logger.info("Starting TFLStatusStore")
    Agent.start_link(fn -> status end, name: __MODULE__)
  end

  def all, do: Agent.get(__MODULE__, & &1)

  def fetch(name), do: Enum.find(all(), fn line -> line.name == name end)

  def save(%TFLLine{name: nil}), do: {:error, "missing name"}
  def save(%TFLLine{status: nil}), do: {:error, "missing status"}
  def save(s), do: Agent.update(__MODULE__, &upsert(&1, s))

  defp upsert([], s = %TFLLine{}), do: [s]
  defp upsert([%{name: id} | t], s = %TFLLine{name: id}), do: [s | t]
  defp upsert([h | t], s = %TFLLine{}), do: [h | upsert(t, s)]

  defp initial_status do
    @tfl_service.lines()
    |> @tfl_service.status()
    |> Enum.map(&to_tfl_line/1)
  end

  defp to_tfl_line({name, status, description}) do
    time = :calendar.universal_time()
    disrupted_on = if status != "Good Service", do: time

    %TFLLine{
      name: name,
      status: status,
      status_verbose: description,
      last_disruption_on: disrupted_on,
      last_updated_on: time
    }
  end
end
