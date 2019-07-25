defmodule Londibot.TFLStatusStoreTest do
  use ExUnit.Case

  import Mox

  alias Londibot.TFLStatusStore
  alias Londibot.TFLLine

  setup do
    set_mox_global()

    World.new()
    |> World.with_disruption(line: "circle", status: "Severe Delays", description: "Description about delays")
    |> World.create()

    {:ok, %{}}
  end

  test "loads all lines with current status on start" do
    TFLStatusStore.start_link()
    lines = TFLStatusStore.all()

    assert 15 == length(lines)
  end

  test "loads last_disruption_on for disrupted lines" do
    TFLStatusStore.start_link()

    circle = TFLStatusStore.fetch("circle")
    victoria = TFLStatusStore.fetch("victoria")

    assert "Severe Delays" == circle.status
    assert "Description about delays" == circle.description
    assert nil != circle.last_updated_on
    assert nil != circle.last_disruption_on

    assert "Good Service" == victoria.status
    assert "" == victoria.description
    assert nil != circle.last_updated_on
    assert nil == victoria.last_disruption_on
  end

  test "can update an existing line" do
    TFLStatusStore.start_link()
    TFLStatusStore.save(%TFLLine{name: :victoria, status: "Grumpy Service"})

    assert %TFLLine{name: :victoria, status: "Grumpy Service"} == TFLStatusStore.fetch(:victoria)
  end

  test "can't update line without a name" do
    TFLStatusStore.start_link()

    assert {:error, "missing name"} == TFLStatusStore.save(%TFLLine{status: "Grumpy Service"})
  end

  test "can't update line with empty status" do
    TFLStatusStore.start_link()

    assert {:error, "missing status"} == TFLStatusStore.save(%TFLLine{name: :victoria})
  end
end
