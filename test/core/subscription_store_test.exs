defmodule Londibot.SubscriptionStoreTest do
  use ExUnit.Case
  doctest Londibot.SubscriptionStore

  alias Londibot.SubscriptionStore
  alias Londibot.Subscription

  setup do
    {:ok, pid, id} = SubscriptionStore.start_link(%Subscription{channel_id: "12345"})
    {:ok, server_pid: pid, subscription_id: id}
  end

  test "retrieves the current subscription state", %{subscription_id: id} do
    {:ok, subscription} = SubscriptionStore.fetch(id)
    assert "12345" == subscription.channel_id
  end

  test "saves new subscription status", %{subscription_id: id} do
    {:ok, id, _subscription} =
      %Subscription{channel_id: "6789"}
      |> SubscriptionStore.save(id)

    {:ok, subscription} = SubscriptionStore.fetch(id)
    assert subscription.channel_id == "6789"
  end

  test "Subscription store exits upon non-existent pid" do
    assert {:error, "Invalid id"} == SubscriptionStore.fetch(9999)
  end
end
