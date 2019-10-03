defmodule Londibot.Commands.CommandRunner do
  alias Londibot.Commands.Command
  alias Londibot.Subscription

  @tfl_service Application.get_env(:londibot, :tfl_service)
  @subscription_store Application.get_env(:londibot, :subscription_store)

  def execute(%Command{command: :help, params: ["subscribe"]}) do
    message = """
    *NAME*
    londibot-subcribe – Subscribe to a tube line(s) disruption notifications

    *SYNOPSIS*
    londibot subscribe line1, line2, ...

    *OPTIONS*
    circle, district, dlr, hammersmith & city, london overground, metropolitan, \
    waterloo & city, bakerloo, central, jubilee, northern, picadilly, victoria, \
    tfl rail, tram

    *DESCRIPTION*
    Creates a subscription to said lines so that every time that any kind of disruption\
    happens in the TFL line, it's sent via message. This includes all changes to/from delays,\
    line closures, etc. except routinary changes like nightly closure and daily opening.

    *EXAMPLES*
    londibot subscribe _dlr_
    londibot subscribe _victoria, metropolitan_

    *SEE ALSO*
    londibot-unsubscribe
    londibot-subscriptions
    """
    {:ok, message}
  end

  def execute(%Command{command: :help}) do
    message = """
    *Londibot commands usage:*

    1. `londibot status`
      Display the current status of TFL lines

    2. `londibot disruptions`
      Display current disruptions throughout all lines

    3. `londibot subscribe [lines]`
      Subscribe to notifications on any disruptions for the lines

    4. `londibot unsubscribe [lines]`
      Unsubscribe to the notifications

    5. `londibot subscriptions`
      List all existing subscriptions

    6. `londibot help`
      Show this help

    Use `londibot COMMAND help` to see command help details.
    """
    {:ok, message}
  end

  def execute(%Command{command: :status}) do
    message =
      @tfl_service.lines!()
      |> @tfl_service.status!()
      |> to_status_message()

    {:ok, message}
  end

  def execute(%Command{command: :disruptions}) do
    message =
      @tfl_service.lines!()
      |> @tfl_service.status!()
      |> @tfl_service.disruptions()
      |> to_disruption_message()

    {:ok, message}
  end

  def execute(%Command{command: :subscriptions, channel_id: channel_id}) do
    message =
      @subscription_store.all()
      |> Enum.filter(fn %Subscription{channel_id: c} -> c == channel_id end)
      |> to_subscriptions_message()

    {:ok, message}
  end

  def execute(%Command{command: :subscribe, params: p, channel_id: channel, service: s}) do
    channel
    |> fetch_subscription(s)
    |> Subscription.with(p)
    |> @subscription_store.save()

    {:ok, "Subscription saved!"}
  end

  def execute(%Command{command: :unsubscribe, params: p, channel_id: channel, service: s}) do
    channel
    |> fetch_subscription(s)
    |> Subscription.without(p)
    |> @subscription_store.save()

    {:ok, "Subscription saved!"}
  end

  def execute(_), do: {:error, "The command you just tried doesn't exist!"}

  defp fetch_subscription(channel_id, service) do
    case @subscription_store.fetch(channel_id) do
      nil -> %Subscription{channel_id: channel_id, service: service}
      subscription -> subscription
    end
  end

  defp to_subscriptions_message(subscriptions) do
    message =
      subscriptions
      |> Enum.map(fn x -> Map.get(x, :tfl_lines) end)
      |> List.flatten()
      |> Enum.join(", ")

    if String.length(message) > 0 do
      "You are currently subscribed to: " <> message
    else
      "You are currently not subscribed to any line"
    end
  end

  defp to_disruption_message(disruptions) do
    disruptions
    |> Enum.map(fn {_, _, description} -> ~s(#{description}\n) end)
    |> Enum.join("\n")
  end

  defp to_status_message(statuses) do
    statuses
    |> Enum.map(&status/1)
    |> Enum.join("\n")
  end

  defp status({name, "Good Service", _}), do: "✅ #{name}: Good Service"
  defp status({name, "Closed", _}), do: "🚫 #{name}: Closed"
  defp status({name, "Service Closed", _}), do: "🚫 #{name}: Service Closed"
  defp status({name, "Not Running", _}), do: "🚫 #{name}: Not Running"
  defp status({name, status, _}), do: "⚠️ #{name}: #{status}"
end
