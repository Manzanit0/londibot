defmodule LondibotWeb.PageController do
  use LondibotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
