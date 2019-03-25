defmodule Tetris99.Player.Server do
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def get_name(pid) do
    GenServer.call(pid, {:get_name})
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
    lobby_name = lobby |> Tetris99.Lobby.Server.get_name()
    Tetris99.Player.Registry |> Registry.register(lobby_name, name)
    Logger.debug("#{name} joined #{lobby_name}")
    {:reply, :ok, state}
  end

  def handle_call({:get_name}, _from, state) do
    %{name: name} = state
    {:reply, name, state}
  end
end
