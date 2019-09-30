defmodule LondibotWeb.DashboardView do
  use LondibotWeb, :view

  import Ecto.Query

  def disruptions_data(_conn) do
    query =
      from c in "status_changes",
      where: c.new_status != "Good Service" and c.new_status != "Service Closed",
      select: {c.tfl_line, count(c.id)},
      group_by: c.tfl_line,
      order_by: [desc: count(c.id)]

    Londibot.Repo.all(query)
  end
end
