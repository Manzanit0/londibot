defmodule Londibot.SubscriptionStoreTest do
  use ExUnit.Case, async: :true

  alias Londibot.Subscription
  alias Londibot.SubscriptionStore

  test "can save multiple subscriptions" do
    SubscriptionStore.start_link(%Subscription{channel_id: 55})
    SubscriptionStore.save(%Subscription{channel_id: 33})

    assert %Subscription{channel_id: 55} == SubscriptionStore.fetch(55)
    assert %Subscription{channel_id: 33} == SubscriptionStore.fetch(33)
  end

  test "can update an existing subscription" do
    SubscriptionStore.start_link(%Subscription{channel_id: 55})
    SubscriptionStore.save(%Subscription{channel_id: 55, tfl_lines: ["value"]})

    assert %Subscription{channel_id: 55, tfl_lines: ["value"]} == SubscriptionStore.fetch(55)
  end

  test "retrieves all subscriptions" do
    SubscriptionStore.start_link(%Subscription{channel_id: "55"})
    SubscriptionStore.save(%Subscription{channel_id: "33"})

    expected = [
      %Subscription{channel_id: "55"},
      %Subscription{channel_id: "33"}]

    assert expected  == SubscriptionStore.all()
  end

  test "can't save subscriptions without a channel_id" do
    SubscriptionStore.start_link([])
    result = SubscriptionStore.save(%Subscription{tfl_lines: ["value"]})

    assert {:error, "missing channel_id"} == result
  end
end
