defmodule Londibot do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = String.to_integer(System.get_env("PORT") || "4000")

    children = [
      {Plug.Cowboy, scheme: :http, plug: Londibot.Router, options: [port: port]},
      {Londibot.SubscriptionStore, []},
      {Londibot.DisruptionWorker, forever: true}
    ]

    opts = [strategy: :one_for_one, name: Londibot.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
