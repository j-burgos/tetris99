defmodule Tetris99.Lobby.Supervisor do
  use Supervisor

  def start_link(_init_arg) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_lobby(name) do
    Supervisor.start_child(__MODULE__, [name])
  end

  def init(_) do
    children = [
      worker(Tetris99.Lobby.Server, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
