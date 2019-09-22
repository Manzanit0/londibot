defmodule LondibotWeb.TelegramControllerTest do
  use LondibotWeb.ConnCase

  test "returns success message with correct headers", %{conn: conn} do
    World.new()
    |> World.create()

    body = %{"message" => %{"from" => %{"id" => "123"}, "text" => "/subscribe victoria"}}

    response =
      conn
      |> post("/api/telegram")
      |> json_response(200)

    expected =
      {200,
       [
         {"cache-control", "max-age=0, private, must-revalidate"},
         {"content-type", "application/json; charset=utf-8"}
       ],
       "{\"text\":\"Subscription saved!\",\"parse_mode\":\"markdown\",\"method\":\"sendMessage\",\"chat_id\":\"123\"}"}

    assert expected == response
  end
end
