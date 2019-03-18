defmodule Londibot do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Londibot.Router, options: [port: 8085]}
    ]

    opts = [strategy: :one_for_one, name: Londibot.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
