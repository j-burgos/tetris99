defmodule Chat.Application do
  use Application
  require Logger

  def start(_type, _args) do
    nodes = Application.get_env(:chat, :nodes)

    children = [
      {Chat.Room.Supervisor, []},
      {Chat.User.Supervisor, []},
      {Chat.Distribution, nodes},
      {Chat.Room.Server, "default-room"}
    ]

    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
