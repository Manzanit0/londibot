defmodule LondibotWeb.SlackController do
  use LondibotWeb, :controller

  def post(conn, _params) do
    msg = Londibot.Web.Handlers.SlackHandler.handle!(conn)
    send_resp(conn, 200, msg)
  end
end
