defmodule Tetris99.Player do
  use GenServer
  require Logger

  def start_link(username) do
    GenServer.start_link(__MODULE__, username)
  end

  def get_name(pid) do
    GenServer.call(pid, {:get_name})
  end

  def join(pid, lobby_pid) do
    GenServer.cast(pid, {:join, lobby_pid})
  end

  # GenServer callbacks
  def init(player_name) do
    {:ok, %{name: player_name}}
  end

  def handle_call({:get_name}, _from, state) do
    %{name: player_name} = state
    {:reply, player_name, state}
  end

  def handle_cast({:join, lobby_pid}, _from, state) do
    %{name: player_name} = state
    lobby_name = lobby_pid |> Tetris99.Lobby.get_name()
    Tetris99.Lobby.Registry |> Registry.register(lobby_name, player_name)
    {:noreply, state}
  end
end
