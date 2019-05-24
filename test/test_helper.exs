# When running tests with --no-start flag we need
# to spin up other dependencies used in the tests.
Application.ensure_all_started(:mox)
Application.ensure_all_started(:httpoison)
Application.ensure_all_started(:plug)

ExUnit.start()
