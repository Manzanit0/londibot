defmodule Londibot.StoreBehaviour do
  @callback all() :: list
  @callback fetch(id :: integer) :: list
  @callback save(subscription :: map) :: any
end
