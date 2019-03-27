defmodule Chat.User.Supervisor do
  require Logger

  @main "default-channel"

  def join_room(user, room) do
    Chat.UserPresence.Registry |> Registry.register(room, user)
  end

  def join_lobby(user) do
    user |> join_room(@main)
  end
end
