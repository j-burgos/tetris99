defmodule Tetris99.Player.Server do
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def join(pid, lobby) do
    GenServer.call(pid, {:join, lobby})
  end

  # Genserver
  def init(name) do
    Logger.debug("Player #{name} connected")
    {:ok, %{name: name}}
  end

  def handle_call({:join, lobby}, _from, state) do
    %{name: name} = state
    Tetris99.Lobby.Players |> Registry.register(lobby, name)
    {:reply, :ok, state}
  end
end
