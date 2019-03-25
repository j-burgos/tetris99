defmodule Tetris99.Lobby.Server do
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(lobby_name) do
    {:via, Registry, {Tetris99.Lobby.Registry, lobby_name, lobby_name}}
  end

  def players(lobby_pid) do
    GenServer.call(lobby_pid, {:get_players})
  end

  def get_name(lobby_pid) do
    GenServer.call(lobby_pid, {:get_name})
  end

  # Genserver callback methods
  def init(lobby_name) do
    Logger.debug("Started lobby: #{lobby_name}")
    {:ok, %{name: lobby_name, players: []}}
  end

  def handle_call({:get_name}, _from, state) do
    %{:name => name} = state
    {:reply, name, state}
  end

  def handle_call({:get_players}, _from, state) do
    %{name: lobby_name} = state
    players = Tetris99.Lobby.Registry |> Registry.lookup(lobby_name)
    {:reply, players, state}
  end

  def handle_cast({:remove_player, player}, state) do
    updated_players = state.players |> List.delete(player)
    {:noreply, %{state | players: updated_players}}
  end
end
