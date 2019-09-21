defmodule Londibot.Application do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Londibot.Repo,
      {Londibot.StatusBroker, []},
      {Londibot.DisruptionWorker, Londibot.DisruptionWorker.default_params()},
      LondibotWeb.Endpoint
    ]

    Logger.info("Started Londibot application")

    opts = [strategy: :one_for_one, name: Londibot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LondibotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
