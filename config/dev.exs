use Mix.Config

config :londibot, :slack_token, System.get_env("LONDIBOT_SLACK")
config :londibot, :telegram_token, System.get_env("LONDIBOT_TELEGRAM")

config :londibot, :tfl_app_id, System.get_env("TFL_APP_ID")
config :londibot, :tfl_app_key, System.get_env("TFL_APP_KEY")

config :logger, level: :debug

config :londibot, :tfl_service, Londibot.TFL
config :londibot, :notifier, Londibot.Notifier
config :londibot, :subscription_store, Londibot.SubscriptionStore
