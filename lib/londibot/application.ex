defmodule Londibot.Application do
  use Application

  require Logger

  @env Application.get_env(:londibot, :environment)
  @tfl_service Application.get_env(:londibot, :tfl_service)

  def start(_type, _args) do
    children = [
      Londibot.Repo,
      {Londibot.StatusBroker, []},
      {Londibot.DisruptionWorker, Londibot.DisruptionWorker.default_params()},
      LondibotWeb.Endpoint
    ]

    Logger.info("Started Londibot application")

    opts = [strategy: :one_for_one, name: Londibot.Supervisor]
    ret_val = Supervisor.start_link(children, opts)

    load_status_worker(@env)

    ret_val
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LondibotWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # NB: When running tests, the application starts up before the mocks are set
  # up, so it is a much simpler a approach to simply startup the worker with an
  # empty status and cache it once @tfl_service is set up in each test.
  # Another approach? -> https://elixirforum.com/t/designing-an-agent-with-side-effects-on-start-link/25576
  defp load_status_worker(:test), do: nil

  defp load_status_worker(_),
    do:
      Agent.cast(Londibot.StatusBroker, fn _ ->
        @tfl_service.lines!() |> @tfl_service.status!()
      end)
end
