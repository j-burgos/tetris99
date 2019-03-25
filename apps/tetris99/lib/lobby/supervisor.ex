defmodule Tetris99.Lobby.Supervisor do
  use DynamicSupervisor

  require Logger

  @sup_name __MODULE__
  @max_players Application.get_env(:tetris99, :max_players)

  def start_link(_init_arg) do
    @sup_name |> DynamicSupervisor.start_link([], name: @sup_name)
  end

  def start_lobby(name) do
    @sup_name |> DynamicSupervisor.start_child({Tetris99.Lobby.Server, name})
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def players(lobby_pid) do
    lobby_name = lobby_pid |> Tetris99.Lobby.Server.get_name()
    Tetris99.Player.Registry |> Registry.lookup(lobby_name)
  end

  def find_or_create do
    lobbies = @sup_name |> Supervisor.which_children()

    available_lobby =
      lobbies
      |> Enum.find(fn {_, pid, _, _} -> has_room(pid) end)

    if available_lobby do
      {_, pid, _, _} = available_lobby
      pid
    else
      next = length(lobbies) + 1
      {:ok, pid} = start_lobby("lobby-#{next}")
      pid
    end
  end

  defp has_room(lobby_pid) do
    lobby_name = lobby_pid |> Tetris99.Lobby.Server.get_name()
    player_count = Tetris99.Player.Registry |> Registry.count_match(lobby_name, :_)
    player_count < @max_players
  end
end
