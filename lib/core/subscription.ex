defmodule Londibot.Subscription do
  defstruct service: "slack",
            type: :full_report,
            channel_id: nil,
            cron: nil
end
