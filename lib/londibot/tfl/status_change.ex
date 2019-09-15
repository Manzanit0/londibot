defmodule Londibot.StatusChange do
  use Ecto.Schema

  schema "status_changes" do
    field(:line, :string)
    field(:previous_status, :string)
    field(:new_status, :string)
    field(:description, :string)

    timestamps(type: :utc_datetime)
  end
end
