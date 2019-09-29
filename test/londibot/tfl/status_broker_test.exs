defmodule Londibot.StatusBrokerTest do
  use ExUnit.Case, async: false

  import Mox

  alias Londibot.StatusBroker
  alias Londibot.StatusChange

  setup :set_mox_global

  test "fetches latest statuses from TFL API" do
    World.new()
    |> World.with_disruption(
      line: "circle",
      status: "Severe Delays",
      description: "Description about delays"
    )
    |> World.create()

    status = StatusBroker.get_latest!()

    assert status == [
             {"circle", "Severe Delays", "Description about delays"},
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
           ]
  end

  test "upon fetch, statuses are cached" do
    World.new()
    |> World.with_disruption(
      line: "circle",
      status: "Severe Delays",
      description: "Description about delays"
    )
    |> World.create()

    # Cache initial status
    StatusBroker.get_changes!()

    status = StatusBroker.get_cached()

    assert status == [
             {"circle", "Severe Delays", "Description about delays"},
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
           ]
  end

  test "calculates the diff between the cached and the latest statuses" do
    World.new()
    |> World.with_disruption(
      line: "circle",
      status: "Severe Delays",
      description: "",
      starts_after: 0,
      lasts_for: 1
    )
    |> World.with_disruption(
      line: "northen",
      status: "Everything is broken",
      description: "oops",
      starts_after: 1,
      lasts_for: 4
    )
    |> World.create()

    # Cache initial status
    StatusBroker.get_changes!()

    diff = StatusBroker.get_changes!()

    assert [
             %StatusChange{
               tfl_line: "circle",
               previous_status: "Severe Delays",
               new_status: "Good Service",
               description: ""
             },
             %StatusChange{
               tfl_line: "northen",
               previous_status: "Good Service",
               new_status: "Everything is broken",
               description: "oops"
             }
           ] == diff
  end

  test "fetches non-routinary changes – nightly shutdown and morning start" do
    World.new()
    |> World.with_disruption(
      line: "circle",
      status: "Service Closed",
      description: "Train service resumes later this morning",
      starts_after: 0,
      lasts_for: 1
    )
    |> World.with_disruption(
      line: "circle",
      status: "Severe Delays",
      description: "",
      starts_after: 3,
      lasts_for: 1
    )
    |> World.create()

    # Cache initial status
    StatusBroker.get_changes!()

    # Good Service -> Service Closed (nightly)
    assert [] == StatusBroker.get_non_routinary_changes!()

    # Service Closed -> Good Service (daily)
    assert [] == StatusBroker.get_non_routinary_changes!()

    # Good Service -> Severe Delays (non-routinary change)
    assert [
             %StatusChange{
               description: "",
               tfl_line: "circle",
               new_status: "Severe Delays",
               previous_status: "Good Service"
             }
           ] == StatusBroker.get_non_routinary_changes!()
  end
end
