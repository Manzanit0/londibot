defmodule LondibotWeb.DashboardView do
  use LondibotWeb, :view

  import Ecto.Query

  def disruptions_data(_conn) do
    # Create a query
    query =
      from c in "status_changes",
      where: c.new_status != "Good Service" and c.new_status != "Service Closed",
      select: {c.tfl_line, count(c.id)},
      group_by: c.tfl_line

    Londibot.Repo.all(query)
  end
end
