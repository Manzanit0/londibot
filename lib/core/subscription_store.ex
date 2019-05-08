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

  def start_link(s = %Subscription{}) do
    Agent.start_link(fn -> [s] end, name: __MODULE__)
  end

  def all do
    Agent.get(__MODULE__, & &1)
  end

  def fetch(id) when is_integer(id) do
    all
    |> Enum.find(fn subscription -> subscription.id == id end)
  end

  def save(s = %Subscription{}) do
    Agent.update(__MODULE__, &(upsert(&1, s)))
  end

  defp upsert([], s = %Subscription{}), do: [s]
  defp upsert([%{id: id}|t], s = %Subscription{id: id}), do: [s|t]
  defp upsert([h|t], s = %Subscription{}), do: [h|upsert(t, s)]
end
