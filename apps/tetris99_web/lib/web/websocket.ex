defmodule Tetris99.Web.WebSocket do
  require Logger

  @behaviour :cowboy_websocket
  def init(req, state) do
    opts = %{:idle_timeout => 60000 * 5}
    {:cowboy_websocket, req, state, opts}
  end

  def websocket_init(_init_args) do
    {:ok, %{player_pid: nil}}
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

        case Chat.User.Supervisor.start_user(player) do
          {:ok, _pid} -> Logger.debug("Created user")
          {:error, {:already_started, _pid}} -> Logger.debug("Already created")
        end

        resp = %{player: player}
        json = Poison.encode!(resp)
        {:reply, {:text, json}, state}

      %{"action" => "leave", "player" => player} ->
        Logger.info("#{player} left")

      msg ->
        websocket_handle({:unknown, msg}, state)
    end
  end

  def websocket_info(info, state) do
    Logger.debug("Handle info #{inspect(info)} #{inspect(state)}")
    {:ok, state}
  end

  def terminate(reason, _req, _state) do
    # Tetris99.Lobby.Registry.leave(self())
    Logger.debug("Connection terminated #{inspect(reason)}")
    :ok
  end
end
