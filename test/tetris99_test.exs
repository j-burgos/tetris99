defmodule Tetris99Test do
  use ExUnit.Case
  doctest Tetris99

  require Logger

  # test "creates a player" do
  #   player_name = "testuser"
  #   {:ok, pid} = Tetris99.Player.start_link(player_name)
  #   created_player_name = pid |> Tetris99.Player.get_name()
  #   assert created_player_name == player_name
  # end

  test "creates a lobby" do
    lobby_name = "testlobby"
    {:ok, lobby_pid} = Tetris99.Lobby.Supervisor.start_lobby(lobby_name)
    created_lobby = lobby_pid |> Tetris99.Lobby.Server.get_name()
    assert created_lobby == lobby_name
  end

  # test "adds player to a lobby" do
  #   lobby_name = "testlobby"
  #   player_name = "testuser"
  #   {:ok, lobby_pid} = Tetris99.Lobby.start_link(lobby_name)
  #   {:ok, player_pid} = Tetris99.Player.start_link(player_name)
  #   player_pid |> Tetris99.Player.join(lobby_pid)
  #   players_in_lobby = lobby_pid |> Tetris99.Lobby.get_players()
  #   [player] = players_in_lobby
  #   assert length(players_in_lobby) === 1
  #   assert player == {player_pid, player_name}
  # end

  # test "adds max players to a lobby" do
  #   lobby_name = "testlobby"
  #   {:ok, lobby_pid} = Tetris99.Lobby.Supervisorstart_link(lobby_name)
  #   Logger.debug("Lobby: #{inspect(lobby_pid)} #{lobby_name}")

  #   max_players = Application.get_env(:tetris99, :max_players)
  #   iterations = 1..(max_players + 1)
  #   player_names = iterations |> Enum.map(fn n -> "testuser#{n}" end)

  #   player_pids =
  #     player_names
  #     |> Enum.map(fn player_name ->
  #       {:ok, player_pid} = Tetris99.Player.start_link(player_name)
  #       player_pid
  #     end)

  #   player_pids
  #   |> Enum.each(fn player_pid ->
  #     Logger.debug("#{inspect(player_pid)} join #{inspect(lobby_pid)}")
  #     lobby_pid |> Tetris99.Lobby.add_player(player_pid)
  #   end)

  #   players_in_lobby = lobby_pid |> Tetris99.Lobby.get_players()
  #   Logger.debug("#{inspect(players_in_lobby)}")
  #   assert length(players_in_lobby) === 2
  # end
end
