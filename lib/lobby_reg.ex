defmodule Tetris99.Lobby.Registry do
  def start_link() do
    Registry.start_link(
      keys: :duplicate,
      name: __MODULE__,
      partitions: System.schedulers_online()
    )
  end
end
