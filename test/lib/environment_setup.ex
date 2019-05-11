defmodule EnvironmentSetup do
  alias Londibot.Subscription

  defstruct [:disruptions, :subscriptions]

  def new do
    %EnvironmentSetup{disruptions: [], subscriptions: []}
  end

  def with_subscription(env_setup, id, channel_id, lines) do
    with_subscription(env_setup, %Subscription{id: id, channel_id: channel_id, tfl_lines: lines})
  end
  def with_subscription(e = %EnvironmentSetup{subscriptions: subscriptions}, s = %Subscription{}) do
    %EnvironmentSetup{subscriptions: [s | subscriptions]}
  end
end
