defmodule Londibot.Application do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = String.to_integer(System.get_env("PORT") || "4000")

    children = [
      Londibot.Repo,
      {Plug.Cowboy, scheme: :http, plug: Londibot.Web.Router, options: [port: port]},
      {Londibot.StatusBroker, []},
      {Londibot.DisruptionWorker, Londibot.DisruptionWorker.default_params()}
    ]

    Logger.info("Started londibot on port #{port}")

    opts = [strategy: :one_for_one, name: Londibot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
