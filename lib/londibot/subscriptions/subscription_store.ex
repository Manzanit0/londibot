defmodule Londibot.SubscriptionStore do
  require Logger

  alias Londibot.Subscription
  alias Londibot.Repo

  @behaviour Londibot.StoreBehaviour

  def all do
    # TODO - lazy pagination optimization
    Repo.all(Subscription)
    |> Enum.map(&atomize_service/1)
  end

  def fetch(channel_id) when is_binary(channel_id) do
    Repo.get_by(Subscription, channel_id: channel_id)
    |> atomize_service()
  end

  def save(%{channel_id: nil}), do: {:error, "can't save subscription without channel_id"}

  def save(%{channel_id: channel_id, tfl_lines: lines} = subscription) do
    case fetch(channel_id) do
      nil -> insert_subscription(subscription)
      existing -> update_subscription(existing, %{tfl_lines: lines})
    end
  end

  defp insert_subscription(subscription) do
    subscription
    |> changeset()
    |> Repo.insert()
  end

  defp update_subscription(subscription, params) do
    subscription
    |> changeset(params)
    |> Repo.update()
  end

  defp changeset(subscription, params \\ %{}) do
    subscription
    |> stringify_service()
    |> Ecto.Changeset.cast(params, [:channel_id, :service, :tfl_lines])
    |> Ecto.Changeset.validate_required([:channel_id, :service])
  end

  defp atomize_service(nil), do: nil

  defp atomize_service(%Subscription{service: s} = subscription) do
    %Subscription{subscription | service: String.to_atom(s)}
  end

  defp stringify_service(nil), do: nil

  defp stringify_service(%Subscription{service: s} = subscription) do
    %Subscription{subscription | service: to_string(s)}
  end
end
