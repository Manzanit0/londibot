defmodule LondibotWeb.SlackControllerTest do
  use LondibotWeb.ConnCase

  alias LondibotWeb.SlackController

  test "returns success message with correct headers", %{conn: conn} do
    World.new()
    |> World.create()

    response =
      conn
      |> post("/api/slack", %{channel_id: "123", text: "subscribe victoria"})
      |> json_response(200)

    assert response == %{"text" => "Subscription saved!", "response_type" => "in_channel"}
  end

  test "handles SSL checks" do
    ssl_check_request = %{"ssl_check" => "???", "token" => "some-token"}

    assert "Received!" == SlackController.handle!(ssl_check_request)
  end

  test "status request returns all the statuses" do
    World.new()
    |> World.with_disruption(line: "victoria", status: "Severe Delays", description: "oops")
    |> World.create()

    response = SlackController.handle!(%{"channel_id" => "123", "text" => "status"})

    assert response == """
           {\"text\":\"\
           ✅ circle: Good Service\\n\
           ✅ district: Good Service\\n\
           ✅ dlr: Good Service\\n\
           ✅ hammersmith & city: Good Service\\n\
           ✅ london overground: Good Service\\n\
           ✅ metropolitan: Good Service\\n\
           ✅ waterloo & city: Good Service\\n\
           ✅ bakerloo: Good Service\\n\
           ✅ central: Good Service\\n\
           ✅ jubilee: Good Service\\n\
           ✅ northen: Good Service\\n\
           ✅ picadilly: Good Service\\n\
           ⚠️ victoria: Severe Delays\\n\
           ✅ tfl rail: Good Service\\n\
           ✅ tram: Good Service\",\
           \"response_type\":\"in_channel\"}\
           """
  end

  test "disruptions request returns only the description of the disrupted statuses" do
    World.new()
    |> World.with_disruption(
      line: "bakerloo",
      status: "Severe Delays",
      description: "BAKERLOO LINE: oops"
    )
    |> World.create()

    response = SlackController.handle!(%{"channel_id" => "123", "text" => "disruptions"})

    assert response == "{\"text\":\"BAKERLOO LINE: oops\\n\",\"response_type\":\"in_channel\"}"
  end

  test "an ephemeral response is sent if the command doesn't exist" do
    response = SlackController.handle!(%{"channel_id" => "123", "text" => "break pls!"})

    assert response == "{\"text\":\"The command you just tried doesn't exist!\"}"
  end
end
