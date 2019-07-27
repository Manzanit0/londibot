defmodule Londibot.Repo do
  use Ecto.Repo,
    otp_app: :londibot,
    adapter: Ecto.Adapters.Postgres
end
