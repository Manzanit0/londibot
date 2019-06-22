defmodule WorldTest do
  use ExUnit.Case, async: true

  alias Londibot.Subscription

  test "creates an empty Environment struct" do
    assert World.new() == %World{disruptions: [], subscriptions: []}
  end

  test "adds a subscription as parameters" do
    %{subscriptions: subscriptions} =
      World.new()
      |> World.with_subscription("id", "channel_id", ["victoria"])

    assert subscriptions == [
             %Subscription{
               service: :slack,
               id: "id",
               channel_id: "channel_id",
               tfl_lines: ["victoria"]
             }
           ]
  end

  test "adds a subscription as struct" do
    s = %Subscription{
      service: :slack,
      id: "id",
      channel_id: "channel_id",
      tfl_lines: ["victoria"]
    }

    %{subscriptions: subscriptions} =
      World.new()
      |> World.with_subscription(s)

    assert subscriptions == [s]
  end

  test "creates the subscription store mock based on the setup struct" do
    World.new()
    |> World.with_subscription("5", "ASD890", ["victoria"])
    |> World.with_subscription("9", "123QWE", ["circle", "bakerloo"])
    |> World.create()

    store = Application.get_env(:londibot, :subscription_store)

    assert store.all() == [
             %Subscription{
               service: :slack,
               id: "9",
               channel_id: "123QWE",
               tfl_lines: ["circle", "bakerloo"]
             },
             %Subscription{
               service: :slack,
               id: "5",
               channel_id: "ASD890",
               tfl_lines: ["victoria"]
             }
           ]

    assert store.fetch("5") == %Subscription{
             service: :slack,
             id: "5",
             channel_id: "ASD890",
             tfl_lines: ["victoria"]
           }

    assert store.fetch("9") == %Subscription{
             service: :slack,
             id: "9",
             channel_id: "123QWE",
             tfl_lines: ["circle", "bakerloo"]
           }
  end

  test "adds a disruption as parameters" do
    %{disruptions: disruptions} =
      World.new()
      |> World.with_disruption("victoria", "Minor delays", "because...")

    assert disruptions == [{"victoria", "Minor delays", "because..."}]
  end

  test "adds a disruption as tuple" do
    %{disruptions: disruptions} =
      World.new()
      |> World.with_disruption({"victoria", "Minor delays", "because..."})

    assert disruptions == [{"victoria", "Minor delays", "because..."}]
  end

  test "creates the tfl service mock based on the setup struct" do
    World.new()
    |> World.with_disruption("victoria", "Minor delays", "because...")
    |> World.with_disruption("circle", "Line closed", "boom!")
    |> World.create()

    tfl_service = Application.get_env(:londibot, :tfl_service)
    lines = tfl_service.lines()
    assert length(lines) == 15

    statuses = tfl_service.status(lines)

    assert Enum.member?(statuses, {"victoria", "Minor delays", "because..."})
    assert Enum.member?(statuses, {"circle", "Line closed", "boom!"})
    assert Enum.member?(statuses, {"bakerloo", "Good Service", ""})

    disruptions = tfl_service.disruptions(statuses)

    assert disruptions == [
             {"circle", "Line closed", "boom!"},
             {"victoria", "Minor delays", "because..."}
           ]
  end

  test "adds both subscriptions and disruptions to the environment" do
    World.new()
    |> World.with_subscription("5", "ASD890", ["victoria"])
    |> World.with_subscription("9", "123QWE", ["circle", "bakerloo"])
    |> World.with_disruption("victoria", "Minor delays", "because...")
    |> World.with_disruption("circle", "Line closed", "boom!")
    |> World.create()

    store = Application.get_env(:londibot, :subscription_store)

    assert store.all() == [
             %Subscription{
               service: :slack,
               id: "9",
               channel_id: "123QWE",
               tfl_lines: ["circle", "bakerloo"]
             },
             %Subscription{
               service: :slack,
               id: "5",
               channel_id: "ASD890",
               tfl_lines: ["victoria"]
             }
           ]

    tfl_service = Application.get_env(:londibot, :tfl_service)
    lines = tfl_service.lines()
    statuses = tfl_service.status(lines)
    disruptions = tfl_service.disruptions(statuses)

    assert disruptions == [
             {"circle", "Line closed", "boom!"},
             {"victoria", "Minor delays", "because..."}
           ]
  end
end
