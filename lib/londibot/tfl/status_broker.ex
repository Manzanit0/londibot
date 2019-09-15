defmodule Londibot.StatusBroker do
  use Agent

  require Logger

  alias Londibot.StatusChange
  alias Londibot.TFL

  @tfl_service Application.get_env(:londibot, :tfl_service)

  def start_link(_), do: start_link()

  def start_link do
    Logger.info("Starting StatusBroker")

    status = @tfl_service.lines!() |> @tfl_service.status!()
    Agent.start_link(fn -> status end, name: __MODULE__)
  end

  def get_latest! do
    @tfl_service.lines!()
    |> @tfl_service.status!()
    |> cache()
  end

  def get_cached do
    Agent.get(__MODULE__, & &1)
  end

  def get_non_routinary_changes! do
    Enum.filter(get_changes!(), fn change -> not TFL.routinary?(change) end)
  end

  def get_changes! do
    cached = get_cached()
    latest = get_latest!()

    for {line2, old_status, _} <- cached,
        {line1, new_status, desc} <- latest,
        line1 == line2 and old_status != new_status,
        into: [] do
      StatusChange.new()
      |> StatusChange.with_line(line1)
      |> StatusChange.with_previous_status(old_status)
      |> StatusChange.with_new_status(new_status)
      |> StatusChange.with_description(desc)
    end
  end

  defp cache(statuses) do
    Agent.update(__MODULE__, fn _ -> statuses end)
    statuses
  end
end
