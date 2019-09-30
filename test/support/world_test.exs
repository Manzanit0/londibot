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
      |> World.with_disruption(
        line: "victoria",
        status: "Minor delays",
        description: "because...",
        starts_after: 1,
        lasts_for: 2
      )

    assert disruptions == [{"victoria", "Minor delays", "because...", 1, 2}]
  end

  test "adds a disruption as tuple" do
    %{disruptions: disruptions} =
      World.new()
      |> World.with_disruption({"victoria", "Minor delays", "because..."})

    assert disruptions == [{"victoria", "Minor delays", "because..."}]
  end

  test "creates the tfl service mock based on the setup struct" do
    World.new()
    |> World.with_disruption(line: "victoria", status: "Minor delays", description: "because...")
    |> World.with_disruption(line: "circle", status: "Line closed", description: "boom!")
    |> World.create()

    tfl_service = Application.get_env(:londibot, :tfl_service)
    lines = tfl_service.lines!()
    assert length(lines) == 15

    statuses = tfl_service.status!(lines)

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
    |> World.with_disruption(line: "victoria", status: "Minor delays", description: "because...")
    |> World.with_disruption(line: "circle", status: "Line closed", description: "boom!")
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
    lines = tfl_service.lines!()
    statuses = tfl_service.status!(lines)
    disruptions = tfl_service.disruptions(statuses)

    assert disruptions == [
             {"circle", "Line closed", "boom!"},
             {"victoria", "Minor delays", "because..."}
           ]
  end

  test "disruptions last for an explicit amount of time" do
    World.new()
    |> World.with_disruption(
      line: "circle",
      status: "Severe Delays",
      description: "oops",
      starts_after: 0,
      lasts_for: 2
    )
    |> World.with_disruption(
      line: "northen",
      status: "Everything is broken",
      description: "oops",
      starts_after: 1,
      lasts_for: 2
    )
    |> World.with_disruption(
      line: "victoria",
      status: "Shut down",
      description: "oops",
      starts_after: 4,
      lasts_for: 1
    )
    |> World.create()

    service = Application.get_env(:londibot, :tfl_service)
    assert [{"circle", "Severe Delays", "oops"}] == service.disruptions(nil)

    assert [{"northen", "Everything is broken", "oops"}, {"circle", "Severe Delays", "oops"}] ==
             service.disruptions(nil)

    assert [{"northen", "Everything is broken", "oops"}] == service.disruptions(nil)
    assert [] == service.disruptions(nil)
    assert [{"victoria", "Shut down", "oops"}] == service.disruptions(nil)
  end

  test "statuses last for an explicit amount of time" do
    World.new()
    |> World.with_disruption(
      line: "circle",
      status: "Severe Delays",
      description: "oops",
      starts_after: 0,
      lasts_for: 2
    )
    |> World.with_disruption(
      line: "northen",
      status: "Everything is broken",
      description: "oops",
      starts_after: 1,
      lasts_for: 2
    )
    |> World.with_disruption(
      line: "victoria",
      status: "Shut down",
      description: "oops",
      starts_after: 4,
      lasts_for: 1
    )
    |> World.create()

    service = Application.get_env(:londibot, :tfl_service)

    assert [
             {"circle", "Severe Delays", "oops"},
             {"district", "Good Service", ""},
             {"dlr", "Good Service", ""},
             {"hammersmith & city", "Good Service", ""},
             {"london overground", "Good Service", ""},
             {"metropolitan", "Good Service", ""},
             {"waterloo & city", "Good Service", ""},
             {"bakerloo", "Good Service", ""},
             {"central", "Good Service", ""},
             {"jubilee", "Good Service", ""},
             {"northen", "Good Service", ""},
             {"picadilly", "Good Service", ""},
             {"victoria", "Good Service", ""},
             {"tfl rail", "Good Service", ""},
             {"tram", "Good Service", ""}
           ] == service.status!(nil)

    assert [
             {"circle", "Severe Delays", "oops"},
             {"district", "Good Service", ""},
             {"dlr", "Good Service", ""},
             {"hammersmith & city", "Good Service", ""},
             {"london overground", "Good Service", ""},
             {"metropolitan", "Good Service", ""},
             {"waterloo & city", "Good Service", ""},
             {"bakerloo", "Good Service", ""},
             {"central", "Good Service", ""},
             {"jubilee", "Good Service", ""},
             {"northen", "Everything is broken", "oops"},
             {"picadilly", "Good Service", ""},
             {"victoria", "Good Service", ""},
             {"tfl rail", "Good Service", ""},
             {"tram", "Good Service", ""}
           ] == service.status!(nil)

    assert [
             {"circle", "Good Service", ""},
             {"district", "Good Service", ""},
             {"dlr", "Good Service", ""},
             {"hammersmith & city", "Good Service", ""},
             {"london overground", "Good Service", ""},
             {"metropolitan", "Good Service", ""},
             {"waterloo & city", "Good Service", ""},
             {"bakerloo", "Good Service", ""},
             {"central", "Good Service", ""},
             {"jubilee", "Good Service", ""},
             {"northen", "Everything is broken", "oops"},
             {"picadilly", "Good Service", ""},
             {"victoria", "Good Service", ""},
             {"tfl rail", "Good Service", ""},
             {"tram", "Good Service", ""}
           ] == service.status!(nil)

    assert [
             {"circle", "Good Service", ""},
             {"district", "Good Service", ""},
             {"dlr", "Good Service", ""},
             {"hammersmith & city", "Good Service", ""},
             {"london overground", "Good Service", ""},
             {"metropolitan", "Good Service", ""},
             {"waterloo & city", "Good Service", ""},
             {"bakerloo", "Good Service", ""},
             {"central", "Good Service", ""},
             {"jubilee", "Good Service", ""},
             {"northen", "Good Service", ""},
             {"picadilly", "Good Service", ""},
             {"victoria", "Good Service", ""},
             {"tfl rail", "Good Service", ""},
             {"tram", "Good Service", ""}
           ] == service.status!(nil)

    assert [
             {"circle", "Good Service", ""},
             {"district", "Good Service", ""},
             {"dlr", "Good Service", ""},
             {"hammersmith & city", "Good Service", ""},
             {"london overground", "Good Service", ""},
             {"metropolitan", "Good Service", ""},
             {"waterloo & city", "Good Service", ""},
             {"bakerloo", "Good Service", ""},
             {"central", "Good Service", ""},
             {"jubilee", "Good Service", ""},
             {"northen", "Good Service", ""},
             {"picadilly", "Good Service", ""},
             {"victoria", "Shut down", "oops"},
             {"tfl rail", "Good Service", ""},
             {"tram", "Good Service", ""}
           ] == service.status!(nil)
  end
end
