defmodule Londibot.StatusChange do
  defstruct [:line, :previous_status, :new_status, :description]
end

defmodule Londibot.StatusBroker do
  use Agent

  require Logger

  alias Londibot.StatusChange

  @tfl_service Application.get_env(:londibot, :tfl_service)

  def start_link do
    Logger.info("Starting StatusBroker")
    Agent.start_link(fn -> [] end, name: __MODULE__)
    get_latest()
  end

  def get_latest do
    @tfl_service.lines()
    |> @tfl_service.status()
    |> cache()
  end

  def get_cached do
    Agent.get(__MODULE__, & &1)
  end

  def get_changes do
    cached = get_cached()
    latest = get_latest()
    for {line2, old_status, _} <- cached,
        {line1, new_status, desc} <- latest,
        line1 == line2 and old_status != new_status,
        into: [] do
      %StatusChange{
        line: line1,
        previous_status: old_status,
        new_status: new_status,
        description: desc
      }
    end
  end

  defp cache(statuses) do
    Agent.update(__MODULE__, fn _ -> statuses end)
    statuses
  end
end
