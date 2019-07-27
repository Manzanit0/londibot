defmodule Util do
  require Logger

  def track_error(error, opts \\ []) do
    optional_head = Keyword.get(opts, :message, "")
    message = "#{optional_head} – #{inspect(error)}"

    case Keyword.get(opts, :severity) do
      :warn -> Logger.warn(message)
      :error -> Logger.error(message)
    end

    if Mix.env() === :prod, do: Bugsnag.report(error)

    error
  end
end
