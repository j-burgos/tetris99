defmodule Tetris99.Lobby.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :lobby_sup)
  end

  def start_lobby(name) do
    Supervisor.start_child(:lobby_sup, [name])
  end

  def init(_) do
    children = [
      worker(Tetris99.Lobby, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
