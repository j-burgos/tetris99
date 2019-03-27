defmodule Chat.Distribution do
  use GenServer
  require Logger

  @name __MODULE__

  def start_link(default) do
    GenServer.start_link(@name, default, name: @name)
  end

  def replicate_users(users) do
    GenServer.cast(@name, {:replicate, users})
  end

  def reconnect(setting) do
    GenServer.cast(@name, {:reconnect, setting})
  end

  def init(nodes) do
    nodes_with_status = connect(nodes)
    {:ok, %{nodes: nodes_with_status, reconnect: true}}
  end

  def handle_cast({:retry, node}, state) do
    Logger.debug("Retrying connection to node #{node}")
    retry = connect([node])
    Logger.debug("Node #{inspect(retry)}")
    {:noreply, %{state | nodes: state.nodes ++ retry}}
  end

  def handle_cast({:replicate, users}, state) do
    %{nodes: nodes, reconnect: reconnect} = state

    if reconnect do
      nodes |> Enum.each(fn {node, _} -> node |> replicate_to_node(users) end)
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:reconnect, setting}, state) do
    %{nodes: nodes} = state

    new_nodes =
      if setting do
        nodenames = nodes |> Enum.map(fn {n, _} -> n end)
        nodenames |> connect()
      else
        nodes
      end

    {:noreply, %{state | nodes: new_nodes, reconnect: setting}}
  end

  def handle_info(msg, state) do
    case msg do
      {:nodedown, nodename} ->
        Logger.warn("Node #{nodename} is down")

        retry =
          if state.reconnect do
            connect([nodename])
          else
            []
          end

        {:noreply, %{state | nodes: state.nodes ++ retry}}

      _ ->
        Logger.debug("Handle info: #{inspect(msg)}")
        {:noreply, state}
    end
  end

  defp replicate_to_node(node, users) do
    :rpc.cast(node, Chat.User.Supervisor, :create_users, [users])
  end

  defp connect(nodes) do
    timeout = 5000
    pid = self()

    nodes_with_status =
      Enum.map(nodes, fn node ->
        case Node.ping(node) do
          :pang ->
            spawn(fn ->
              receive do
                msg -> Logger.debug("Receive #{inspect(msg)}")
              after
                timeout -> GenServer.cast(pid, {:retry, node})
              end
            end)

            {node, :down}

          :pong ->
            Node.monitor(node, true)
            Logger.debug("Node #{node} is alive")

            users =
              Chat.Room.Supervisor.get_users("default-channel") |> Enum.map(fn {_, u} -> u end)

            replicate_to_node(node, users)
            {node, :up}
        end
      end)

    nodes_with_status
  end
end
