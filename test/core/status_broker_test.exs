defmodule Londibot.StatusBrokerTest do
  use ExUnit.Case

  import Mox

  alias Londibot.StatusBroker
  alias Londibot.StatusChange

  setup do
    set_mox_global()

    World.new()
    |> World.with_disruption("circle", "Severe Delays", "Description about delays")
    |> World.create()

    StatusBroker.start_link()

    {:ok, %{}}
  end

  test "fetches latest statuses from TFL API" do
    status = StatusBroker.get_latest()

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

  test "statuses aren't cached until fetched" do
    assert [] == StatusBroker.get_cached()
  end

  test "upon fetch, statuses are cached" do
    StatusBroker.get_latest()
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
    StatusBroker.get_latest()

    World.new()
    |> World.with_disruption("northen", "Everything is broken", "oops")
    |> World.recreate!()

    diff = StatusBroker.get_changes()

    assert [
             %StatusChange{
               line: "circle",
               previous_status: "Severe Delays",
               new_status: "Good Service",
               description: ""
             },
             %StatusChange{
               line: "northen",
               previous_status: "Good Service",
               new_status: "Everything is broken",
               description: "oops"
             }
           ] == diff
  end
end
