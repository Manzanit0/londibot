defmodule Londibot.StatusChange do
  use Ecto.Schema

  alias Ecto.Changeset

  schema "status_changes" do
    field(:tfl_line, :string)
    field(:previous_status, :string)
    field(:new_status, :string)
    field(:description, :string)

    timestamps(type: :utc_datetime)
  end

  def to_changeset(status_change, params \\ %{}) do
    status_change
    |> Changeset.cast(params, [
      :tfl_line,
      :previous_status,
      :new_status,
      :description
    ])
    |> Changeset.validate_required([
      :tfl_line,
      :previous_status,
      :new_status,
      :description
    ])
  end
end
