use Mix.Config

config :londibot, Londibot.Repo,
  database: "londibot_repo",
  username: "postgres",
  hostname: "localhost"


config :londibot, ecto_repos: [Londibot.Repo]

import_config "#{Mix.env()}.exs"
