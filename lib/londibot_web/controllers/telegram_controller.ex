defmodule LondibotWeb.TelegramController do
  use LondibotWeb, :controller

  def post(conn, _params) do
    msg = Londibot.Web.Handlers.TelegramHandler.handle!(conn)
    send_resp(conn, 200, msg)
  end
end
