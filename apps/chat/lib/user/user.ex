defmodule Chat.User.Agent do
  use Agent
  require Logger

  def start_link(name) do
    Agent.start_link(fn -> name end, name: via_tuple(name))
  end

  defp via_tuple(name) do
    {:via, Registry, {Chat.User.Registry, name, name}}
  end

  def join(pid, room_name) do
    name = pid |> Agent.get(fn state -> state end)

    pid
    |> Agent.cast(fn state ->
      Chat.UserPresence.Registry |> Registry.register(room_name, name)
      state
    end)
  end
end
