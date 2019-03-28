defmodule Tetris99.Web.WebSocket do
  require Logger

  @behaviour :cowboy_websocket
  def init(req, state) do
    opts = %{:idle_timeout => 60000 * 5}
    {:cowboy_websocket, req, state, opts}
  end

  def websocket_init(_init_args) do
    {:ok, %{user: nil}}
  end

  def websocket_handle({:unknown, message}, state) do
    Logger.debug("Unknown message #{inspect(message)}")
    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    decode_result = Poison.decode(message)
    {:ok, message} = decode_result
    websocket_handle({:json, message}, state)
  end

  def websocket_handle({:json, message}, state) do
    case message do
      %{"action" => "join", "player" => player} ->
        Logger.info("#{player} joined")

        player |> Chat.User.Supervisor.start_user()

        connected_users =
          Chat.Room.Supervisor.get_connected_users("default-channel")
          |> Enum.map(fn {_, u} -> u end)

        resp = %{player: player, connected_users: connected_users}
        json = Poison.encode!(resp)
        {:reply, {:text, json}, %{state | user: player}}

      %{"action" => "broadcast", "message" => bmessage} ->
        %{user: user} = state
        Chat.Room.Supervisor.broadcast(user, bmessage)
        Chat.Distribution.broadcast(user, bmessage)
        {:reply, {:text, "ok"}, state}

      %{"action" => "leave", "player" => player} ->
        Logger.info("#{player} left")

      msg ->
        websocket_handle({:unknown, msg}, state)
    end
  end

  def websocket_info(info, state) do
    Logger.debug("Handle info #{inspect(info)}")
    {:reply, {:text, info}, state}
  end

  def terminate(reason, _req, state) do
    %{user: user} = state
    conns = Chat.User.Supervisor.get_connections(user)
    Logger.debug("Connection terminated #{inspect(reason)}")

    if length(conns) == 1 do
      Chat.User.Supervisor.stop(user)
      Chat.User.Supervisor.show_connected_to_users(user, :disconnected)
    end

    :ok
  end
end
