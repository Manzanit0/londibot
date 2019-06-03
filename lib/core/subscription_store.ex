defmodule Londibot.Subscription do
  defstruct [:id, :channel_id, :tfl_lines]
end

defmodule Londibot.StoreBehaviour do
  @callback all() :: list
  @callback fetch(id :: integer) :: list
  @callback save(subscription :: map) :: any
end

defmodule Londibot.SubscriptionStore do
  use Agent

  alias Londibot.Subscription

  @behaviour Londibot.StoreBehaviour

  def start_link(s = %Subscription{}), do: start_link([s])
  def start_link([]), do: Agent.start_link(fn -> [] end, name: __MODULE__)
  def start_link(subscriptions) when is_list(subscriptions) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
    Enum.each(subscriptions, &save/1)
  end

  def all, do: Agent.get(__MODULE__, & &1)

  def fetch(id), do: Enum.find(all(), fn subscription -> subscription.channel_id == id end)

  def save(%Subscription{channel_id: nil}), do: {:error, "missing channel_id"}
  def save(s), do: Agent.update(__MODULE__, &(upsert(&1, s)))

  defp upsert([], s = %Subscription{}), do: [s]
  defp upsert([%{channel_id: id}|t], s = %Subscription{channel_id: id}), do: [s|t]
  defp upsert([h|t], s = %Subscription{}), do: [h|upsert(t, s)]
end
