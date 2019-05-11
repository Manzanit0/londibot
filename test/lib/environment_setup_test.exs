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

  test "creates the environment mocks based on the setup struct" do
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
end
