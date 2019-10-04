defmodule Londibot.Commands.HelpTest do
  use ExUnit.Case, async: true

  alias Londibot.Commands.Help

  describe "description/0 for every available command" do
    test "subscribe" do
      assert is_binary(Help.description(:subscribe))
    end

    test "unsubscribe" do
      assert is_binary(Help.description(:unsubscribe))
    end

    test "subscriptions" do
      assert is_binary(Help.description(:subscriptions))
    end

    test "status" do
      assert is_binary(Help.description(:status))
    end

    test "disruptions" do
      assert is_binary(Help.description(:disruptions))
    end

    test "generic" do
      assert is_binary(Help.description(:empty))
    end
  end
end
