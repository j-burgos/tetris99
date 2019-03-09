defmodule Tetris99.Lobby.Supervisor do
  use DynamicSupervisor

  require Logger

  @sup_name __MODULE__

  def start_link(_init_arg) do
    @sup_name |> DynamicSupervisor.start_link([], name: @sup_name)
  end

  def start_lobby(name) do
    @sup_name |> DynamicSupervisor.start_child({Tetris99.Lobby.Server, name})
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end