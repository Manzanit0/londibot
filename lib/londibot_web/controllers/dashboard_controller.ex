defmodule LondibotWeb.DashboardController do
  use LondibotWeb, :controller

  def index(conn, _params) do
    render(conn, "dashboard.html")
  end
end
