defmodule Londibot.SubscriptionTest do
  use ExUnit.Case

  alias Londibot.Subscription

  test "can subscribe and unsubscribe to lines subsequently" do
    Subscription.new()
    |> Subscription.with("victoria")
    |> assert_contains_line("victoria")
    |> Subscription.with("central line")
    |> assert_contains_line("victoria")
    |> assert_contains_line("central line")
    |> Subscription.with("london overground")
    |> assert_contains_line("victoria")
    |> assert_contains_line("central line")
    |> assert_contains_line("london overground")
    |> Subscription.without("victoria")
    |> assert_doesnt_contain_line("victoria")
    |> assert_contains_line("central line")
    |> assert_contains_line("london overground")
    |> Subscription.without("london overground")
    |> assert_doesnt_contain_line("victoria")
    |> assert_doesnt_contain_line("london overground")
    |> assert_contains_line("central line")
  end

  test "can subscribe and unsubscribe to lines in batch" do
    Subscription.new()
    |> Subscription.with(["victoria", "central line", "london overground"])
    |> assert_contains_line("victoria")
    |> assert_contains_line("central line")
    |> assert_contains_line("london overground")
    |> Subscription.without(["victoria", "london overground"])
    |> assert_doesnt_contain_line("victoria")
    |> assert_doesnt_contain_line("london overground")
    |> assert_contains_line("central line")
  end

  def assert_contains_line(%{tfl_lines: lines} = subscription, line) do
    assert Enum.member?(lines, line)

    subscription
  end

  def assert_doesnt_contain_line(%{tfl_lines: lines} = subscription, line) do
    assert !Enum.member?(lines, line)

    subscription
  end
end
