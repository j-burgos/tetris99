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
    @conn_reg |> Registry.register(name, "websocket")

    case r do
      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:ok, _pid} ->
        name |> join_room(@default_channel)

        users =
          Chat.Room.Supervisor.get_connected_users("default-channel")
          |> Enum.map(fn {_, u} -> u end)

        Chat.Distribution.replicate_users(users)

        r
    end
  end

  def show_connected(user, connected_user, status) do
    @conn_reg
    |> Registry.dispatch(user, fn conns ->
      Logger.debug("#{inspect(conns)}")

      conns
      |> Enum.each(fn {conn, _} ->
        payload =
          if status === :connected do
            %{"user:connected" => connected_user}
          else
            %{"user:disconnected" => connected_user}
          end

        msg = Poison.encode!(payload)
        Logger.debug("#{inspect(msg)} to #{inspect(conn)}")
        conn |> Process.send(msg, [])
      end)
    end)
  end

  def show_connected_to_users(name, status \\ :connected) do
    @presence_reg
    |> Registry.dispatch(@default_channel, fn entries ->
      entries
      |> Enum.each(fn {_, username} ->
        if username != name do
          Logger.debug("Show to #{username} that #{name} connected")
          username |> show_connected(name, status)
        end
      end)
    end)
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
