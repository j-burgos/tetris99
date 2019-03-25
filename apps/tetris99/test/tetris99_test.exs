defmodule Tetris99Test do
  use ExUnit.Case
  doctest Tetris99

  require Logger

  defp join_multiple_players(lobby_pid, player_count) do
    iterations = 1..player_count
    player_names = iterations |> Enum.map(fn n -> "testuser#{n}" end)

    player_pids =
      player_names
      |> Enum.map(fn player_name ->
        {:ok, player_pid} = Tetris99.Player.Server.start_link(player_name)
        player_pid
      end)

    player_pids
    |> Enum.each(fn player_pid ->
      player_pid |> Tetris99.Player.Server.join(lobby_pid)
    end)
  end

  test "creates a player" do
    player_name = "user"
    {:ok, pid} = Tetris99.Player.Server.start_link(player_name)
    created_player_name = pid |> Tetris99.Player.Server.get_name()
    assert created_player_name == player_name
  end

  test "creates a lobby" do
    lobby_name = "lobby"
    {:ok, lobby_pid} = Tetris99.Lobby.Supervisor.start_lobby(lobby_name)
    created_lobby = lobby_pid |> Tetris99.Lobby.Server.get_name()
    assert created_lobby == lobby_name
  end

  test "adds player to a lobby" do
    lobby_name = "testlobby"
    player_name = "testuser"
    {:ok, lobby_pid} = Tetris99.Lobby.Supervisor.start_lobby(lobby_name)
    {:ok, player_pid} = Tetris99.Player.Server.start_link(player_name)
    player_pid |> Tetris99.Player.Server.join(lobby_pid)
    players_in_lobby = lobby_pid |> Tetris99.Lobby.Supervisor.players()
    [player] = players_in_lobby
    assert length(players_in_lobby) === 1
    assert player == {player_pid, player_name}
  end

  test "adds max players to a lobby" do
    lobby_name = "testlobby2"
    {:ok, lobby_pid} = Tetris99.Lobby.Supervisor.start_lobby(lobby_name)

    max_players = Application.get_env(:tetris99, :max_players)
    lobby_pid |> join_multiple_players(max_players)

    players_in_lobby = lobby_pid |> Tetris99.Lobby.Supervisor.players()
    assert length(players_in_lobby) === 2
  end

  test "finds an existing lobby when there are slots available" do
    lobby_pid = Tetris99.Lobby.Supervisor.find_or_create()
    lobby_pid |> join_multiple_players(1)
    available = Tetris99.Lobby.Supervisor.find_or_create()
    assert lobby_pid == available
  end

  test "creates a new lobby when others already full" do
    lobby_pid = Tetris99.Lobby.Supervisor.find_or_create()
    lobby_pid |> join_multiple_players(2)
    available = Tetris99.Lobby.Supervisor.find_or_create()
    assert lobby_pid != available
  end
end
