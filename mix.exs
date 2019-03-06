defmodule Tetris99.MixProject do
  use Mix.Project

  def project do
    [
      app: :tetris99,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    any_env = [:logger]

    extra_apps =
      case Mix.env() do
        :dev -> any_env ++ [:remix]
        _ -> any_env
      end

    [
      mod: {Tetris99, []},
      extra_applications: extra_apps
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.0"},
      {:plug, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:remix, "~> 0.0.1", only: :dev}
    ]
  end
end
