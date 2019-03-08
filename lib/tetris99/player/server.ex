defmodule Tetris99.Player.Server do
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start(Tetris.Player.Server, name)
  end

  # Genserver
  def init(name) do
    {:ok, %{name: name}}
  end
end
