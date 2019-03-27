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

        resp = %{player: player}
        json = Poison.encode!(resp)
        {:reply, {:text, json}, %{state | user: player}}

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

  def terminate(reason, _req, state) do
    %{user: user} = state
    conns = Chat.User.Supervisor.get_connections(user)
    Logger.debug("Connection terminated #{inspect(reason)}")

    if length(conns) == 1 do
      Chat.User.Supervisor.stop(user)
    end

    :ok
  end
end
