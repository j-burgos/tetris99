defmodule Chat.User.Supervisor do
  use DynamicSupervisor
  require Logger

  @sup_name __MODULE__
  @reg_name Chat.User.Registry
  @conn_reg Chat.Connection.Registry
  @presence_reg Chat.UserPresence.Registry
  @default_channel "default-channel"

  def start_link(_init_arg) do
    @sup_name |> DynamicSupervisor.start_link([], name: @sup_name)
  end

  def start_user(name) do
    r = @sup_name |> DynamicSupervisor.start_child({Chat.User.Server, name})

    case r do
      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:ok, _pid} ->
        @conn_reg |> Registry.register(name, "websocket")
        name |> join_room(@default_channel)
        Chat.Distribution.replicate_users([name])
        r
    end
  end

  def get_pid(user) do
    [{pid, _}] = @reg_name |> Registry.lookup(user)
    pid
  end

  def join_room(user, room) do
    user_pid = user |> get_pid
    user_pid |> Chat.User.Server.join(room)
  end

  def get_connections(user) do
    @conn_reg |> Registry.lookup(user)
  end

  def create_users(users) do
    users
    |> Enum.each(fn u ->
      start_user(u)
    end)
  end

  def stop(user) do
    user_pid = user |> get_pid
    @sup_name |> DynamicSupervisor.terminate_child(user_pid)
  end

  def init(_) do
    Registry.start_link(keys: :unique, name: @reg_name)
    Registry.start_link(keys: :duplicate, name: @conn_reg)
    Registry.start_link(keys: :duplicate, name: @presence_reg)
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
