use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :londibot, LondibotWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :error

# Configure your database
config :londibot, Londibot.Repo,
  database: "londibot_repo",
  username: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :londibot, :tfl_service, Londibot.TFLMock
config :londibot, :notifier, Londibot.NotifierMock
config :londibot, :subscription_store, Londibot.SubscriptionStoreMock
