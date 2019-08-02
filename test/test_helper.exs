# When running tests with --no-start flag we need
# to spin up other dependencies used in the tests.
Application.ensure_all_started(:mox)
Application.ensure_all_started(:httpoison)
Application.ensure_all_started(:plug)

Londibot.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Londibot.Repo, :manual)

ExUnit.start(exclude: [:skip])
