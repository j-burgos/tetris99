defmodule Chat.Mixfile do
  use Mix.Project

  def project do
    [
      app: :chat,
      version: "0.1.0",
      deps: deps(),
      elixir: "~> 1.8",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      start_permanent: Mix.env() == :prod
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
      mod: {Chat.Application, []},
      extra_applications: extra_apps
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:remix, "~> 0.0.1", only: :dev}
    ]
  end
end
