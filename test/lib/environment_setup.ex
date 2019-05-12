defmodule EnvironmentSetup do
  import Mox

  alias Londibot.Subscription

  defstruct disruptions: [], subscriptions: []

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
    # Since the mocks set here are for all the tests throughout the
    # project, and the project doesn't use the 'verify_on_exit' mechanic,
    # I've decided to set a high number (99) so the functions can be called
    # as much as needed.
    Application.get_env(:londibot, :subscription_store)
    |> expect(:all, 99, fn -> subscriptions end)
    |> expect(:fetch, 99, fn id -> Enum.find(subscriptions, &(&1.id == id)) end)

    lines = ["victoria", "circle", "bakerloo"]
    statuses = statuses_with_disruptions(lines, disruptions)

    Application.get_env(:londibot, :tfl_service)
    |> expect(:lines, 99, fn -> lines end)
    |> expect(:status, 99, fn _ -> statuses end)
    |> expect(:disruptions, 99, fn _ -> disruptions end)
  end

  defp statuses_with_disruptions(lines, nil), do: statuses_with_disruptions(lines, [])

  defp statuses_with_disruptions(lines, disruptions) do
    for line <- lines do
      Enum.find(disruptions, {line, "Good Service", ""}, fn {name, _, _} ->
        String.downcase(name) == line
      end)
    end
  end
end
