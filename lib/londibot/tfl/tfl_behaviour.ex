defmodule Londibot.TFLBehaviour do
  @callback lines!() :: [String.t()]
  @callback status!(list) :: String.t()
  @callback status!(String.t()) :: String.t()
  @callback disruptions(list) :: list
end
