use Mix.Config

config :londibot, ecto_repos: [Londibot.Repo]

config :londibot, environment: Mix.env()

# Environment variables
config :londibot, :slack_token, System.get_env("LONDIBOT_SLACK")
config :londibot, :telegram_token, System.get_env("LONDIBOT_TELEGRAM")
config :londibot, :tfl_app_id, System.get_env("TFL_APP_ID")
config :londibot, :tfl_app_key, System.get_env("TFL_APP_KEY")

# Stubbed modules
config :londibot, :tfl_service, Londibot.TFL
config :londibot, :notifier, Londibot.Notifier
config :londibot, :subscription_store, Londibot.SubscriptionStore

# Configures the endpoint
config :londibot, LondibotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "X79H9ePAiveqOcdv+q2Tw9Hxa7BCGY676eAnHz/uvaQME/TO77jjb1/3sVgLGUWF",
  render_errors: [view: LondibotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Londibot.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
