defmodule LondibotWeb.SlackControllerTest do
  use LondibotWeb.ConnCase

  test "returns success message with correct headers", %{conn: conn} do
    World.new()
    |> World.create()

    response =
      conn
      |> post("/api/slack", %{channel_id: "123", text: "subscribe victoria"})
      |> json_response(200)

    assert response == %{"text" => "Subscription saved!", "response_type" => "in_channel"}
  end
end
