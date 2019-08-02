defmodule World do
  import Mox

  alias Londibot.Subscription

  defstruct disruptions: [], subscriptions: [], notifications: 0

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

  def new, do: %World{}

  def with_subscription(env_setup, id, channel_id, line) when is_binary(line),
    do: with_subscription(env_setup, id, channel_id, [line])

  def with_subscription(env_setup, id, channel_id, lines),
    do:
      with_subscription(env_setup, %Subscription{
        service: :slack,
        id: id,
        channel_id: channel_id,
        tfl_lines: lines
      })

  def with_subscription(e = %World{subscriptions: subscriptions}, s = %Subscription{}),
    do: %World{e | subscriptions: [s | subscriptions]}

  def with_disruption(_, []), do: {:error, "Empty disruption config"}

  def with_disruption(env_setup, config)
      when is_list(config) do
    line = Keyword.get(config, :line)
    status = Keyword.get(config, :status)
    description = Keyword.get(config, :description)
    starts_after = Keyword.get(config, :starts_after, 0)
    lasts_for = Keyword.get(config, :lasts_for, 99)

    with_disruption(env_setup, {line, status, description, starts_after, lasts_for})
  end

  def with_disruption(e = %World{disruptions: disruptions}, disruption),
    do: %World{e | disruptions: [disruption | disruptions]}

  def with_notifications(e = %World{}, notifications),
    do: %World{e | notifications: notifications}

  def create(%World{subscriptions: subscriptions, disruptions: disruptions, notifications: n}) do
    setup_subscription_store(subscriptions)
    setup_tfl_service(disruptions)
    setup_notifier(n)
  end

  def setup_notifier(expected_notifications) do
    Application.get_env(:londibot, :notifier)
    |> expect(:send, expected_notifications, fn x -> x end)
  end

  defp setup_subscription_store(subscriptions) do
    Application.get_env(:londibot, :subscription_store)
    |> expect(:save, @expected_executions, fn s -> {:ok, s} end)
    |> expect(:all, @expected_executions, fn -> subscriptions end)
    |> expect(:fetch, @expected_executions, fn id -> Enum.find(subscriptions, &(&1.id == id)) end)
  end

  defp setup_tfl_service(disruptions) do
    tfl_service = Application.get_env(:londibot, :tfl_service)

    set_disruptions_expectations = fn nth_execution ->
      expect(tfl_service, :disruptions, fn _ ->
        filter_by_execution(disruptions, nth_execution)
      end)
    end

    set_statuses_expectations = fn nth_execution ->
      expect(tfl_service, :status, fn _ ->
        get_statuses_with_disruptions(@lines, disruptions, nth_execution)
      end)
    end

    expect(tfl_service, :lines, @expected_executions, fn -> @lines end)
    Enum.each(0..@expected_executions, set_statuses_expectations)
    Enum.each(0..@expected_executions, set_disruptions_expectations)
  end

  defp get_statuses_with_disruptions(lines, disruptions, execution) do
    for line <- lines do
      disruptions
      |> filter_by_execution(execution)
      |> Enum.find({line, "Good Service", ""}, fn disruption -> same_line?(disruption, line) end)
    end
  end

  defp filter_by_execution(disruptions, execution) do
    disruptions
    |> Enum.filter(&in_execution_range?(&1, execution))
    |> strip_moment_properties()
  end

  # Basically, we're looking for the disruption which is
  # after the :starts_after but before the :lasts_for
  defp in_execution_range?({_, _, _, starts, ends}, execution),
    do: starts <= execution and starts + ends > execution

  defp strip_moment_properties({line, status, desc, _, _}),
    do: {line, status, desc}

  defp strip_moment_properties(statuses) when is_list(statuses),
    do: Enum.map(statuses, &strip_moment_properties/1)

  defp same_line?({disrupted_line, _, _}, line),
    do: String.downcase(disrupted_line) == String.downcase(line)
end
