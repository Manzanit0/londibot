defmodule Londibot.SubscriptionStoreTest do
  use ExUnit.Case, async: :true

  alias Londibot.SubscriptionStore

  test "can save multiple subscriptions" do
    SubscriptionStore.start_link(%{id: 55})
    SubscriptionStore.save(%{id: 33})

    assert %{id: 55} == SubscriptionStore.fetch(55)
    assert %{id: 33} == SubscriptionStore.fetch(33)
  end

  test "can update an existing subscription" do
    SubscriptionStore.start_link(%{id: 55})
    SubscriptionStore.save(%{id: 55, property: "value"})

    assert %{id: 55, property: "value"} == SubscriptionStore.fetch(55)
  end
end
