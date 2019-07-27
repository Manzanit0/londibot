defmodule Londibot.Repo do
  use Ecto.Repo,
    otp_app: :londibot,
    adapter: Ecto.Adapters.Postgres
end

defmodule Londibot.Repo.Subscription do
  use Ecto.Schema

  schema "subscriptions" do
    field :channel_id, :string
    field :tfl_lines, :string
    field :service, :string
  end
end
