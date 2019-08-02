use Mix.Config

config :londibot, ecto_repos: [Londibot.Repo]

import_config "#{Mix.env()}.exs"
