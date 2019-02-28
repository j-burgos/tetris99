defmodule Tetris99.Lobby.Registry do
  require Logger

  def start_link() do
    Memento.Table.create! Tetris99.Lobby.Model
    Supervisor.start_link(
      [
        {Registry,
         keys: :duplicate, name: __MODULE__, partitions: System.schedulers_online()}
      ],
      strategy: :one_for_one
    )
  end

  def join(player) do
    lobby = Tetris99.Lobby.Model.find_available
    %Tetris99.Lobby.Model{name: lobby_name} = lobby
    Registry.register(__MODULE__, lobby_name, player)
  end

  def leave pid do
    keys = Registry.keys(__MODULE__, pid)
    Logger.info inspect(keys)
    Enum.each keys, fn key ->
      Registry.unregister(__MODULE__, key)
    end
  end

  def all do
    Registry.keys(__MODULE__, self())
  end
end
