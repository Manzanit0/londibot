defmodule EnvironmentSetupTest do
  use ExUnit.Case, async: :true

  alias Londibot.Subscription

  test "creates an empty Environment struct" do
    assert EnvironmentSetup.new() == %EnvironmentSetup{disruptions: [], subscriptions: []}
  end

  test "adds a subscription as parameters" do
    %{subscriptions: subscriptions} =
      EnvironmentSetup.new()
      |> EnvironmentSetup.with_subscription("id", "channel_id", ["victoria"])

    assert subscriptions == [%Subscription{id: "id", channel_id: "channel_id", tfl_lines: ["victoria"]}]
  end

  test "adds a subscription as struct" do
    s = %Subscription{id: "id", channel_id: "channel_id", tfl_lines: ["victoria"]}

    %{subscriptions: subscriptions} =
      EnvironmentSetup.new()
      |> EnvironmentSetup.with_subscription(s)

    assert subscriptions == [s]
  end
end
