defmodule Londibot.SubscriptionStore do
  use GenServer

  def start_link(subscription, subscription_id) when is_integer(subscription_id) do
    GenServer.start_link(__MODULE__, subscription, name: via_tuple(subscription_id))
    |> Tuple.append(subscription_id)
  end

  def start_link(subscription) do
    start_link(subscription, System.unique_integer)
  end

  def fetch!(id) do
    GenServer.call(via_tuple(id), :fetch)
  end

  def fetch(id) do
    try do
      fetch!(id)
    catch
      :exit, _ -> {:error, "Invalid id"}
    end
  end

  def save!(subscription, id) do
    GenServer.call(via_tuple(id), {:save, subscription})
    {:ok, id, subscription}
  end

  def save(subscription, id) do
    try do
      save!(subscription, id)
    catch
      :exit, _ -> {:error, "Invalid id"}
    end
  end

  def init(subscription) do
    {:ok, subscription}
  end

  def whereis(subscription_id) do
    case Registry.lookup(:subscriptions_registry, subscription_id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  def handle_call(:fetch, _from, subscription) do
    {:reply, {:ok, subscription}, subscription}
  end

  def handle_call({:save, new_subscription}, _from, subscription) do
    {:reply, {:ok, subscription}, new_subscription}
  end

  defp via_tuple(subscription_id) do
    {:via, Registry, {:subscriptions_registry, subscription_id}}
  end
end
