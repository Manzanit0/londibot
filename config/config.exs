use Mix.Config

config :londibot, :slack_token, System.get_env("LONDIBOT_SLACK")

if Mix.env == :test do
  config :londibot, :tfl_service, Londibot.TFLMock
else
  config :londibot, :tfl_service, Londibot.TFL
end
