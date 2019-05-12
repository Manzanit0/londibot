defmodule EnvironmentSetup do
  import Mox

  alias Londibot.Subscription

  defstruct disruptions: [], subscriptions: []

  # Since the mocks set are for all the tests throughout the project
  # and the project doesn't use the 'verify_on_exit' mechanic,
  # I've decided to set a high number (99) so the functions can be called
  # as much as needed.
  @expected_executions 99

  @lines [
    "circle",
    "district",
    "dlr",
    "hammersmith & city",
    "london overground",
    "metropolitan",
    "waterloo & city",
    "bakerloo",
    "central",
    "jubilee",
    "northen",
    "picadilly",
    "victoria",
    "tfl rail",
    "tram"
  ]

  def new, do: %EnvironmentSetup{}

  def with_subscription(env_setup, id, channel_id, line) when is_binary(line),
    do: with_subscription(env_setup, id, channel_id, [line])

  def with_subscription(env_setup, id, channel_id, lines),
    do:
      with_subscription(env_setup, %Subscription{id: id, channel_id: channel_id, tfl_lines: lines})

  def with_subscription(e = %EnvironmentSetup{subscriptions: subscriptions}, s = %Subscription{}),
    do: %EnvironmentSetup{e | subscriptions: [s | subscriptions]}

  def with_disruption(env_setup, line, status, description),
    do: with_disruption(env_setup, {line, status, description})

  def with_disruption(e = %EnvironmentSetup{disruptions: disruptions}, disruption),
    do: %EnvironmentSetup{e | disruptions: [disruption | disruptions]}

  def create(%EnvironmentSetup{subscriptions: subscriptions, disruptions: disruptions}) do
    setup_subscription_store(subscriptions)
    setup_tfl_service(disruptions)
  end

  defp setup_subscription_store(subscriptions) do
    Application.get_env(:londibot, :subscription_store)
    |> expect(:all, @expected_executions, fn -> subscriptions end)
    |> expect(:fetch, @expected_executions, fn id -> Enum.find(subscriptions, &(&1.id == id)) end)
  end

  defp setup_tfl_service(disruptions) do
    statuses = statuses_with_disruptions(@lines, disruptions)

    Application.get_env(:londibot, :tfl_service)
    |> expect(:lines, @expected_executions, fn -> @lines end)
    |> expect(:status, @expected_executions, fn _ -> statuses end)
    |> expect(:disruptions, @expected_executions, fn _ -> disruptions end)
  end

  defp statuses_with_disruptions(lines, disruptions) do
    for line <- lines do
      default = {line, "Good Service", ""}
      Enum.find(disruptions, default, fn disruption -> same_line?(disruption, line) end)
    end
  end

  defp same_line?({disrupted_line, _, _}, line),
    do: String.downcase(disrupted_line) == String.downcase(line)
end
