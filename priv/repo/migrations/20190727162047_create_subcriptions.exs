defmodule Londibot.Repo.Migrations.CreateSubcriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :channel_id, :string
      add :tfl_lines, :string
      add :service, :string
    end
  end
end
