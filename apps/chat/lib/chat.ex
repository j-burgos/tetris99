defmodule Chat.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: Chat.Room.Registry]},
      {Registry, [keys: :duplicate, name: Chat.UserPresence.Registry]},
      {Chat.Room.Supervisor, []},
    ]

    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
