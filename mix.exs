defmodule Londibot.MixProject do
  use Mix.Project

  def project do
    [
      app: :londibot,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Londibot.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, "~> 1.4"},
      {:poison, "~> 3.0"},
      {:bugsnag, "~> 1.7.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:mox, "~> 0.5.0", only: :test},
      {:excoveralls, "~> 0.11.1", only: :test}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/lib"]
  defp elixirc_paths(_), do: ["lib"]
end
