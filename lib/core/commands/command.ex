defmodule Londibot.Commands.Command do
  alias __MODULE__

  defstruct [:command, :params, :channel_id]

  def new(command, params, channel_id) do
    %Command{command: command, params: params, channel_id: channel_id}
  end
end
