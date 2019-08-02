defmodule Londibot.SubscriptionStoreTest do
  use ExUnit.Case, async: true

  alias Londibot.Subscription
  alias Londibot.SubscriptionStore

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Londibot.Repo)
  end

  test "returns nil upon not found sunscription" do
    assert nil == SubscriptionStore.fetch("55")
  end

  test "finds a saved subscription" do
    SubscriptionStore.save(%Subscription{service: :slack, channel_id: "55"})
    subscription = SubscriptionStore.fetch("55")

    assert "55" == subscription.channel_id
    assert :slack == subscription.service
    assert [] == subscription.tfl_lines
    assert is_integer(subscription.id)
  end

  test "can update an existing subscription" do
    SubscriptionStore.save(%Subscription{service: :slack, channel_id: "55"})

    SubscriptionStore.save(%Subscription{
      service: :slack,
      channel_id: "55",
      tfl_lines: ["victoria"]
    })

    subscription = SubscriptionStore.fetch("55")

    assert "55" == subscription.channel_id
    assert :slack == subscription.service
    assert ["victoria"] == subscription.tfl_lines
  end

  test "subscription without service fails to save" do
    {:error, result} = SubscriptionStore.save(%Subscription{channel_id: "123123"})
    assert result.errors == [service: {"can't be blank", [validation: :required]}]
  end

  test "subscription without channel_id fails to save" do
    assert {:error, "can't save subscription without channel_id"} ==
             SubscriptionStore.save(%Subscription{service: :slack})
  end

  test "retrieves all subscriptions" do
    SubscriptionStore.save(%Subscription{service: :slack, channel_id: "55"})
    SubscriptionStore.save(%Subscription{service: :telegram, channel_id: "33"})

    [s1, s2] = SubscriptionStore.all()

    assert s1.service == "slack"
    assert s1.channel_id == "55"
    assert s2.service == "telegram"
    assert s2.channel_id == "33"
  end
end
