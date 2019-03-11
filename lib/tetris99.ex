defmodule Tetris99 do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: Tetris99.Lobby.Registry]},
      {Registry, [keys: :duplicate, name: Tetris99.Player.Registry]},
      {Tetris99.Web.Server, []},
      {Tetris99.Lobby.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Tetris99.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
