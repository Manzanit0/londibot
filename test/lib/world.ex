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

  def with_disruption(env_setup, line, status, description),
    do: with_disruption(env_setup, {line, status, description})

  def with_disruption(e = %World{disruptions: disruptions}, disruption),
    do: %World{e | disruptions: [disruption | disruptions]}

  def with_notifications(e = %World{}, notifications),
    do: %World{e | notifications: notifications}

  def create(%World{subscriptions: subscriptions, disruptions: disruptions, notifications: n}) do
    setup_subscription_store(subscriptions)
    setup_tfl_service(disruptions)
    setup_notifier(n)
  end

  def recreate!(%World{} = world) do
    reset_mox_server()
    create(world)
  end

  def setup_notifier(expected_notifications) do
    Application.get_env(:londibot, :notifier)
    |> expect(:send, expected_notifications, fn x -> x end)
  end

  defp setup_subscription_store(subscriptions) do
    Application.get_env(:londibot, :subscription_store)
    |> expect(:save, @expected_executions, fn _ -> :ok end)
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

  defp reset_mox_server do
    Mox.Server.exit(self())
    Application.ensure_all_started(:mox)
  end
end
