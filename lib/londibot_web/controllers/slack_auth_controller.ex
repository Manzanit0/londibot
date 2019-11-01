defmodule LondibotWeb.SlackAuthController do
  use LondibotWeb, :controller

  @slack_auth_url "https://slack.com/api/oauth.access"

  def get!(%Plug.Conn{query_params: %{"code" => code}} = conn, _params) do
    msg =
      authenticate!(code)
      |> parse_body!()
      |> to_official_response()

    send_resp(conn, 200, msg)
  end

  def get!(conn),
    do: send_resp(conn, 400, %{error: "Missing code in the query parameters"} |> Poison.encode!())

  defp authenticate!(code) do
    client_id = System.get_env("SLACK_CLIENT_ID")
    client_secret = System.get_env("SLACK_CLIENT_SECRET")

    @slack_auth_url
    |> with_params(code, client_id, client_secret)
    |> HTTPoison.get!()
  end

  defp parse_body!(response) do
    response
    |> Map.get(:body)
    |> Poison.decode!()
  end

  defp to_official_response(%{"error" => _}),
    do: Poison.encode!(%{error: "There has been an error when trying to authenticate against Slack."})

  defp to_official_response(resp),
      do: Poison.encode!(%{message: "Authentication succesful! Check your workspace for @londibot!"})

  defp with_params(url, code, client_id, client_secret), do:
    "#{url}?code=#{code}&client_id=#{client_id}&client_secret=#{client_secret}"
end
