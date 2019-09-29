defmodule LondibotWeb.TelegramControllerTest do
  use LondibotWeb.ConnCase

  test "returns success message with correct headers", %{conn: conn} do
    World.new()
    |> World.create()

    body = %{"message" => %{"from" => %{"id" => "123"}, "text" => "/subscribe victoria"}}

    response =
      conn
      |> post("/api/telegram", body)
      |> json_response(200)

    assert response == %{
             "chat_id" => "123",
             "method" => "sendMessage",
             "parse_mode" => "markdown",
             "text" => "Subscription saved!"
           }
  end
end
