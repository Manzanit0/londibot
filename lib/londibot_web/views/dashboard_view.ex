defmodule LondibotWeb.DashboardView do
  use LondibotWeb, :view

  import Ecto.Query

  def disruptions_data(_conn) do
    query =
      from c in "status_changes",
        where: c.new_status != "Good Service" and c.new_status != "Service Closed",
        select: {
          row_number() |> over(order_by: [desc: count(c.id)]),
          c.tfl_line,
          count(c.id)
        },
        group_by: c.tfl_line,
        order_by: [desc: count(c.id)]

    query
    |> Londibot.Repo.all()
    |> append_max_count()
  end

  defp append_max_count(records) do
    max =
      records
      |> Enum.map(fn {_index, _line, count} -> count end)
      |> Enum.max()

    Enum.map(records, fn {row, line, count} -> {row, line, count, max} end)
  end
end
