defmodule Londibot.Web.TelegramHandlerTest do
  use ExUnit.Case

  alias Londibot.Web.TelegramHandler

  test "status request returns all the statuses" do
    World.new()
    |> World.with_disruption(line: "victoria", status: "Severe Delays", description: "oops")
    |> World.create()

    response = TelegramHandler.handle(%{"message" => %{"from" => %{"id" => "123"}, "text" => "/status"}})

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
    \"parse_mode\":\"markdown\",\"method\":\"sendMessage\",\"chat_id\":\"123\"}\
    """
  end

  test "disruptions request returns only the description of the disrupted statuses" do
    World.new()
    |> World.with_disruption(line: "bakerloo", status: "Severe Delays", description: "BAKERLOO LINE: oops")
    |> World.create()

    response = TelegramHandler.handle(%{"message" => %{"from" => %{"id" => "123"}, "text" => "/disruptions"}})

    assert response == """
    {\"text\":\"BAKERLOO LINE: oops\\n\",\
    \"parse_mode\":\"markdown\",\
    \"method\":\"sendMessage\",\
    \"chat_id\":\"123\"}\
    """
  end

  test "an error response is sent if the command doesn't exist" do
    response = TelegramHandler.handle(%{"message" => %{"from" => %{"id" => "123"}, "text" => "break pls!"}})

    assert response == """
    {\"text\":\"The command you just tried doesn't exist!\",\
    \"parse_mode\":\"markdown\",\
    \"method\":\"sendMessage\",\
    \"chat_id\":\"123\"}\
    """
  end
end
