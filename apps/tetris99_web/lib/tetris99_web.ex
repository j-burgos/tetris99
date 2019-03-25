defmodule Tetris99.Web.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Tetris99.Web.Server, []},
    ]

    opts = [strategy: :one_for_one, name: Tetris99.Web.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
