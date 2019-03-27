defmodule Chat.Room.Server do
  use GenServer
  require Logger

  @name __MODULE__

  def start_link({name, users}) do
    GenServer.start_link(@name, {name, users}, name: via_tuple(name))
  end

  defp via_tuple(room_name) do
    {:via, Registry, {Chat.Room.Registry, room_name, room_name}}
  end

  # def players(room_pid) do
  #   GenServer.call(room_pid, {:get_players})
  # end

  # def get_name(room_pid) do
  #   GenServer.call(room_pid, {:get_name})
  # end

  # Genserver callback methods
  def init({room_name, users}) do
    Logger.debug("Started room: #{room_name}")
    {:ok, %{name: room_name, users: users}}
  end

  # def handle_call({:get_name}, _from, state) do
  #   %{:name => name} = state
  #   {:reply, name, state}
  # end

  # def handle_call({:get_users}, _from, state) do
  #   %{name: room_name} = state
  #   users = Chat.Room.Registry |> Registry.lookup(room_name)
  #   {:reply, users, state}
  # end

  # def handle_cast({:remove_player, player}, state) do
  #   updated_players = state.players |> List.delete(player)
  #   {:noreply, %{state | players: updated_players}}
  # end
end
