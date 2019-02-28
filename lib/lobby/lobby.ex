defmodule Tetris99.Lobby do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def add_player(lobby_pid, player) do
    GenServer.cast(lobby_pid, {:add_player, player})
  end

  def get_players(lobby_pid) do
    GenServer.call(lobby_pid, {:get_players})
  end

  # Genserver callback methods
  def init(players) do
    {:ok, %{players: players}}
  end

  def handle_call({:get_players}, _from, state) do
    %{:players => players} = state
    {:reply, players, state}
  end

  def handle_cast({:add_player, player}, %{:players => players}) do
    {:noreply, %{players: players ++ [player]}}
  end
end
