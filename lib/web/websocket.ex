defmodule Tetris99.Web.WebSocket do
  require Logger

  @behaviour :cowboy_websocket
  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def websocket_init(_state) do
    state = %{}
    {:ok, state}
  end

  def websocket_handle({:unknown, message}, state) do
    Logger.info("Unknown message #{inspect(message)}")
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
        lobby = Tetris99.Lobby.Registry.join player
        Logger.info("#{player} joined")
        resp = %{player: player}
        json = Poison.encode!(resp)
        {:reply, {:text, json}, state}

      %{"action" => "leave", "player" => player} ->
        Logger.info("#{player} left the map")

      %{"action" => "move", "player" => player, "position" => position} ->
        %{"x" => x, "y" => y} = position
        Logger.info("#{player} move to position #{x}, #{y}")

      msg ->
        websocket_handle({:unknown, msg}, state)
    end
  end

  def websocket_info(info, state) do
    Logger.info("Handle info #{inspect(info)}")
    {:ok, state}
  end

  def terminate(reason, _req, _state) do
    Tetris99.Lobby.Registry.leave self()
    Logger.info("Connection terminated #{inspect(reason)}")
    :ok
  end
end
