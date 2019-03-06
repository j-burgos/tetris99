defmodule Tetris99.Web.WebSocket do
  require Logger

  alias Tetris99.{Player}

  @behaviour :cowboy_websocket
  def init(req, state) do
    {:cowboy_websocket, req, state}
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

    case decode_result do
      {:ok, json} ->
        websocket_handle({:json, json}, state)

      msg ->
        websocket_handle({:unknown, msg}, state)
    end
  end

  def websocket_handle({:json, message}, state) do
    case message do
      %{"action" => "join", "player" => player} ->
        {:ok, pid} = Player.start_link(player)
        Logger.info("#{player} joined")
        resp = %{player: player}
        json = Poison.encode!(resp)
        new_state = %{state | player_pid: pid}
        {:reply, {:text, json}, new_state}

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
