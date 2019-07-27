defmodule Londibot.Commands.Command do
  alias __MODULE__

  defstruct [:command, :params, :channel_id, :service]

  def new(command, params), do: new(command, params, nil)

  def new(command, params, channel_id) do
    %Command{command: command, params: params, channel_id: channel_id}
  end

  def with_channel_id(%Command{} = c, channel_id) do
    %Command{c | channel_id: channel_id}
  end

  def with_service(%Command{} = c, service) do
    %Command{c | service: service}
  end
end
