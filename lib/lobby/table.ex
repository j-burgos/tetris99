defmodule Tetris99.Lobby.Model do
  require Logger

  use Memento.Table,
    attributes: [:id, :name, :slots],
    type: :ordered_set,
    autoincrement: true


  def find_available do
    max_slots = 2
    guards = [
      {:>, :slots, 0},
    ]
    available_lobbies = Memento.transaction! fn ->
      Memento.Query.select(Tetris99.Lobby.Model, guards)
    end
    case available_lobbies do
      [lobby] ->
        Memento.transaction! fn ->
          %Tetris99.Lobby.Model{name: lobby_name, slots: slots} = lobby
          Logger.info "Adding to lobby #{lobby_name}"
          Memento.Query.write(%{lobby | slots: slots - 1})
          lobby
        end
      [] ->
        Memento.transaction! fn ->
          lobbies_count = length(Memento.Query.all(Tetris99.Lobby.Model)) + 1
          lobby_name = "lobby-#{lobbies_count}"
          Logger.info "Creating lobby #{lobby_name}"
          Memento.Query.write(%Tetris99.Lobby.Model{name: lobby_name, slots: max_slots - 1})
        end
    end
  end
end
