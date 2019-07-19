defmodule Londibot.Subscription do
  alias Londibot.Subscription

  defstruct(
    id: "",
    channel_id: nil,
    tfl_lines: [],
    service: nil
  )

  def new() do
    %Subscription{}
  end

  def with(%Subscription{} = s, new_line) when is_binary(new_line), do: Subscription.with(s, [new_line])

  def with(%Subscription{tfl_lines: lines} = s, new_lines) do
    final =
      lines
      |> Kernel.++(new_lines)
      |> Enum.uniq()
      |> curate_list()
    %Subscription{s | tfl_lines: final}
  end

  def without(%Subscription{} = s, line) when is_binary(line), do: Subscription.without(s, [line])

  def without(%Subscription{tfl_lines: lines} = s, unwanted_lines) do
    final =
      lines
      |> Kernel.--(unwanted_lines)
      |> Enum.uniq()
      |> curate_list()
    %Subscription{s | tfl_lines: final}
  end

  defp curate_list(lines) do
    lines
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn x -> x != "" end)
  end
end
