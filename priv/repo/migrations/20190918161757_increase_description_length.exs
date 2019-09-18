defmodule Londibot.Repo.Migrations.IncreaseDescriptionLength do
  use Ecto.Migration

  def change do
    alter table(:status_changes) do
      modify :description, :string, size: 20000
    end
  end
end
