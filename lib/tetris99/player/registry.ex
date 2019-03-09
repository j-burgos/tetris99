defmodule Tetris99.Player.Registry do
  use Supervisor
  def start_link(_init_arg) do
    Registry.start_link(keys: :duplicate, name: Tetris99.Player.Registry)
  end
end
