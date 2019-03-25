defmodule Tetris99.Web.Mixfile do
  use Mix.Project

  def project do
    [
      app: :tetris99_web,
      version: "0.1.0",
      deps: deps(),
      elixir: "~> 1.8",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      start_permanent: Mix.env() == :prod,
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Tetris99.Web.Application, []},
      extra_applications: [:logger, :tetris99]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.0"},
      {:plug, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:tetris99, in_umbrella: true}
    ]
  end
end
