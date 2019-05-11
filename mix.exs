defmodule Londibot.MixProject do
  use Mix.Project

  def project do
    [
      app: :londibot,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env),
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Londibot, []}
    ]
  end

  defp deps do
    [
      {:mox, "~> 0.5.0"},
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, "~> 1.4"},
      {:poison, "~> 4.0.1"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/lib"]
  defp elixirc_paths(_), do: ["lib"]
end
