defmodule Chat.User.Server do
  use GenServer
  require Logger

  @name __MODULE__
  @reg_name Chat.User.Registry
  @presence_reg Chat.UserPresence.Registry

  def start_link(name) do
    GenServer.start_link(@name, name, name: via_tuple(name))
  end

  def join(pid, room) do
    pid |> GenServer.call({:join, room})
  end

  defp via_tuple(name) do
    {:via, Registry, {@reg_name, name, name}}
  end

  # Genserver callback methods
  def init(name) do
    Logger.debug("Started user: #{name}")
    {:ok, %{name: name}}
  end

  def handle_call({:join, room}, _from, state) do
    %{name: name} = state
    keys = @presence_reg |> Registry.keys(self())

    if keys |> Enum.all?(fn k -> k != room end) do
      @presence_reg |> Registry.register(room, name)
    end

    {:reply, :ok, state}
  end
end
