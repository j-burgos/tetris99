defmodule Chat.Room.Server do
  use GenServer
  require Logger

  @name __MODULE__
  @reg_name Chat.Room.Registry

  def start_link(name) do
    GenServer.start_link(@name, name, name: via_tuple(name))
  end

  defp via_tuple(room_name) do
    {:via, Registry, {@reg_name, room_name, room_name}}
  end

  # Genserver callback methods
  def init(room_name) do
    Logger.debug("Started room: #{room_name}")
    {:ok, %{name: room_name}}
  end
end
