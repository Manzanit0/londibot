defmodule Londibot.StatusChange do
  use Ecto.Schema

  alias __MODULE__
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

  def new do
    %StatusChange{}
  end

  def with_line(%StatusChange{} = sc, line),
    do: %StatusChange{sc | tfl_line: line}

  def with_previous_status(%StatusChange{} = sc, previous_status),
    do: %StatusChange{sc | previous_status: previous_status}

  def with_new_status(%StatusChange{} = sc, new_status),
    do: %StatusChange{sc | new_status: new_status}

  def with_description(%StatusChange{} = sc, description),
    do: %StatusChange{sc | description: description}
end
