defmodule Tetris99 do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Tetris99.Web.Server, []),
      worker(Tetris99.Lobby.Registry, [])
    ]
    opts = [strategy: :one_for_one, name: Tetris99.Supervisor]
    pid = Supervisor.start_link(children, opts)
    Logger.info "Application started"

    pid
  end
end
