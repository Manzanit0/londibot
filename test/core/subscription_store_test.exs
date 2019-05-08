defmodule Londibot.SubscriptionStoreTest do
  use ExUnit.Case, async: :true

  alias Londibot.Subscription
  alias Londibot.SubscriptionStore

  test "can save multiple subscriptions" do
    SubscriptionStore.start_link(%Subscription{id: 55})
    SubscriptionStore.save(%Subscription{id: 33})

    assert %Subscription{id: 55} == SubscriptionStore.fetch(55)
    assert %Subscription{id: 33} == SubscriptionStore.fetch(33)
  end

  test "can update an existing subscription" do
    SubscriptionStore.start_link(%Subscription{id: 55})
    SubscriptionStore.save(%Subscription{id: 55, channel_id: "value"})

    assert %Subscription{id: 55, channel_id: "value"} == SubscriptionStore.fetch(55)
  end

  test "retrieves all subscriptions" do
    SubscriptionStore.start_link(%Subscription{id: 55, channel_id: "55"})
    SubscriptionStore.save(%Subscription{id: 33, channel_id: "33"})

    expected = [
      %Subscription{id: 55, channel_id: "55"},
      %Subscription{id: 33, channel_id: "33"}]
    assert expected  == SubscriptionStore.all
  end
end
