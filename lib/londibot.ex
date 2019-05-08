defmodule Londibot do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Plug.Cowboy, scheme: :http, plug: Londibot.Router, options: [port: 8090]},
      supervisor(Registry, [:unique, :subscriptions_registry])
    ]

    opts = [strategy: :one_for_one, name: Londibot.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
