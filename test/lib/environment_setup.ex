defmodule EnvironmentSetup do
  import Mox

  alias Londibot.Subscription

  defstruct [:disruptions, :subscriptions]

  def new do
    %EnvironmentSetup{disruptions: [], subscriptions: []}
  end

  def with_subscription(env_setup, id, channel_id, lines) do
    with_subscription(env_setup, %Subscription{id: id, channel_id: channel_id, tfl_lines: lines})
  end

  def with_subscription(%EnvironmentSetup{subscriptions: subscriptions}, s = %Subscription{}) do
    %EnvironmentSetup{subscriptions: [s | subscriptions]}
  end

  def create(%EnvironmentSetup{subscriptions: subscriptions}) do
    # Since the mocks set here are for all the tests throughout the
    # project, and the project doesn't use the 'verify_on_exit' mechanic,
    # I've decided to set a high number so the functions can be called
    # as much as needed.
    Application.get_env(:londibot, :subscription_store)
    |> expect(:all, 99, fn -> subscriptions end)
    |> expect(:fetch, 99, fn id -> Enum.find(subscriptions, &(&1.id == id)) end)
  end
end
