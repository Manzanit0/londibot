defmodule EnvironmentSetupTest do
  use ExUnit.Case, async: true

  alias Londibot.Subscription

  test "creates an empty Environment struct" do
    assert EnvironmentSetup.new() == %EnvironmentSetup{disruptions: [], subscriptions: []}
  end

  test "adds a subscription as parameters" do
    %{subscriptions: subscriptions} =
      EnvironmentSetup.new()
      |> EnvironmentSetup.with_subscription("id", "channel_id", ["victoria"])

    assert subscriptions == [
             %Subscription{id: "id", channel_id: "channel_id", tfl_lines: ["victoria"]}
           ]
  end

  test "adds a subscription as struct" do
    s = %Subscription{id: "id", channel_id: "channel_id", tfl_lines: ["victoria"]}

    %{subscriptions: subscriptions} =
      EnvironmentSetup.new()
      |> EnvironmentSetup.with_subscription(s)

    assert subscriptions == [s]
  end

  test "creates the subscription store mock based on the setup struct" do
    EnvironmentSetup.new()
    |> EnvironmentSetup.with_subscription("5", "ASD890", ["victoria"])
    |> EnvironmentSetup.with_subscription("9", "123QWE", ["circle", "bakerloo"])
    |> EnvironmentSetup.create()

    store = Application.get_env(:londibot, :subscription_store)

    assert store.all() == [
             %Subscription{id: "9", channel_id: "123QWE", tfl_lines: ["circle", "bakerloo"]},
             %Subscription{id: "5", channel_id: "ASD890", tfl_lines: ["victoria"]}
           ]

    assert store.fetch("5") == %Subscription{
             id: "5",
             channel_id: "ASD890",
             tfl_lines: ["victoria"]
           }

    assert store.fetch("9") == %Subscription{
             id: "9",
             channel_id: "123QWE",
             tfl_lines: ["circle", "bakerloo"]
           }
  end

  test "adds a disruption as parameters" do
    %{disruptions: disruptions} =
      EnvironmentSetup.new()
      |> EnvironmentSetup.with_disruption("victoria", "Minor delays", "because...")

    assert disruptions == [{"victoria", "Minor delays", "because..."}]
  end

  test "adds a disruption as tuple" do
    %{disruptions: disruptions} =
      EnvironmentSetup.new()
      |> EnvironmentSetup.with_disruption({"victoria", "Minor delays", "because..."})

    assert disruptions == [{"victoria", "Minor delays", "because..."}]
  end

  test "creates the tfl service mock based on the setup struct" do
    EnvironmentSetup.new()
    |> EnvironmentSetup.with_disruption("victoria", "Minor delays", "because...")
    |> EnvironmentSetup.with_disruption("circle", "Line closed", "boom!")
    |> EnvironmentSetup.create()

    tfl_service = Application.get_env(:londibot, :tfl_service)
    lines = tfl_service.lines()
    assert lines == ["victoria", "circle", "bakerloo"]

    statuses = tfl_service.status(lines)

    assert statuses == [
             {"victoria", "Minor delays", "because..."},
             {"circle", "Line closed", "boom!"},
             {"bakerloo", "Good Service", ""}
           ]

    disruptions = tfl_service.disruptions(statuses)

    assert disruptions == [
             {"circle", "Line closed", "boom!"},
             {"victoria", "Minor delays", "because..."}
           ]
  end

  test "adds both subscriptions and disruptions to the environment" do
    EnvironmentSetup.new()
    |> EnvironmentSetup.with_subscription("5", "ASD890", ["victoria"])
    |> EnvironmentSetup.with_subscription("9", "123QWE", ["circle", "bakerloo"])
    |> EnvironmentSetup.with_disruption("victoria", "Minor delays", "because...")
    |> EnvironmentSetup.with_disruption("circle", "Line closed", "boom!")
    |> EnvironmentSetup.create()

    store = Application.get_env(:londibot, :subscription_store)

    assert store.all() == [
             %Subscription{id: "9", channel_id: "123QWE", tfl_lines: ["circle", "bakerloo"]},
             %Subscription{id: "5", channel_id: "ASD890", tfl_lines: ["victoria"]}
           ]

    tfl_service = Application.get_env(:londibot, :tfl_service)
    lines = tfl_service.lines()
    statuses = tfl_service.status(lines)

    assert statuses == [
             {"victoria", "Minor delays", "because..."},
             {"circle", "Line closed", "boom!"},
             {"bakerloo", "Good Service", ""}
           ]
  end
end
