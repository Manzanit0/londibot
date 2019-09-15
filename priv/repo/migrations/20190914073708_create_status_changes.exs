defmodule Londibot.Repo.Migrations.CreateStatusChanges do
  use Ecto.Migration

  def change do
    create table(:status_changes) do
      add :tfl_line, :string
      add :previous_status, :string
      add :new_status, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
