defmodule Tetris99.Lobby do
  use GenServer

  require Logger

  alias Tetris99.{Player, Lobby}

  @max_players Application.get_env(:tetris99, :max_players)

  def start_link(lobby_name) do
    GenServer.start_link(__MODULE__, lobby_name)
  end

  def add_player(lobby_pid, player) do
    GenServer.call(lobby_pid, {:add_player, player})
  end

  def remove_player(lobby_pid, player) do
    GenServer.cast(lobby_pid, {:remove_player, player})
  end

  def get_players(lobby_pid) do
    GenServer.call(lobby_pid, {:get_players})
  end

  def get_name(lobby_pid) do
    GenServer.call(lobby_pid, {:get_name})
  end

  # Genserver callback methods
  def init(lobby_name) do
    {:ok, %{name: lobby_name}}
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

  def handle_call({:add_player, player}, _from, state) do
    %{name: name} = state
    player_count = Lobby.Registry |> Registry.count_match(name, {:_})

    case player_count do
      n when n < @max_players ->
        Logger.debug("Is not full")
        player |> Player.join(self())
        {:reply, :ok, state}

      n ->
        Logger.debug("Already have #{n} players")
        {:reply, :error_lobby_full, state}
    end
  end

  def handle_cast({:remove_player, player}, state) do
    updated_players = state.players |> List.delete(player)
    {:noreply, %{state | players: updated_players}}
  end
end
