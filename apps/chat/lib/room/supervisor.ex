defmodule Chat.Room.Supervisor do
  use DynamicSupervisor
  require Logger

  @sup_name __MODULE__
  @reg_name Chat.Room.Registry

  def start_link(_init_arg) do
    @sup_name |> DynamicSupervisor.start_link([], name: @sup_name)
  end

  def start_room(name) do
    users = Chat.UserPresence.Registry |> Registry.lookup(name)
    @sup_name |> DynamicSupervisor.start_child({Chat.Room.Server, {name, users}})
  end

  def get_users(room) do
    Chat.UserPresence.Registry |> Registry.lookup(room)
  end

  def init(_) do
    Registry.start_link(keys: :unique, name: @reg_name)
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
