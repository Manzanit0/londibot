defmodule Londibot.SubscriptionStore do
  use Agent

  def start_link(initial_subscription) do
    Agent.start_link(fn -> [initial_subscription] end, name: __MODULE__)
  end

  def fetch(id) when is_integer(id) do
    Agent.get(__MODULE__, & &1)
    |> Enum.find(fn subscription -> subscription.id == id end)
  end

  def save(subscription) do
    Agent.update(__MODULE__, &(upsert(&1, subscription)))
  end

  defp upsert([], subscription), do: [subscription]
  defp upsert([h = %{id: id}|t], s = %{id: id}), do: [s|t]
  defp upsert([h|t], subscription), do: [h|upsert(t, subscription)]
end
