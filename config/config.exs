use Mix.Config

config :londibot, :slack_token, System.get_env("LONDIBOT_SLACK")

if Mix.env == :test do
  config :logger, level: :error

  config :londibot, :tfl_service, Londibot.TFLMock
  config :londibot, :notifier, Londibot.NotifierMock
  config :londibot, :subscription_store, Londibot.SubscriptionStoreMock
else
  config :logger, level: :info

  config :londibot, :tfl_service, Londibot.TFL
  config :londibot, :notifier, Londibot.Notifier
  config :londibot, :subscription_store, Londibot.SubscriptionStore
end
