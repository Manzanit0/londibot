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

  def fetch(id) when is_integer(id), do: Enum.find(all(), fn subscription -> subscription.id == id end)

  def save(s = %Subscription{id: nil}), do: save(%Subscription{s | id: System.unique_integer([:monotonic, :positive])})
  def save(s), do: Agent.update(__MODULE__, &(upsert(&1, s)))

  defp upsert([], s = %Subscription{}), do: [s]
  defp upsert([%{id: id}|t], s = %Subscription{id: id}), do: [s|t]
  defp upsert([h|t], s = %Subscription{}), do: [h|upsert(t, s)]
end
