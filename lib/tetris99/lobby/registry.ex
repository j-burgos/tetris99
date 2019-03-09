defmodule Tetris99.Lobby.Registry do
  def start_link(_init_arg) do
    Registry.start_link(keys: :unique, name: Tetris99.Lobby.Registry)
  end
end
