use Mix.Config

config :londibot, :slack_token, System.get_env("LONDIBOT_SLACK")
config :londibot, :telegram_token, System.get_env("LONDIBOT_TELEGRAM")

config :logger, level: :error

config :londibot, :tfl_service, Londibot.TFLMock
config :londibot, :notifier, Londibot.NotifierMock
config :londibot, :subscription_store, Londibot.SubscriptionStoreMock
