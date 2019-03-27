defmodule Tetris99.Web.Server do
  use Supervisor

  def start_link(_init_arg) do
    Supervisor.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_init_args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Tetris99.Web.Routes,
        options: [
          port: System.get_env("PORT") |> String.to_integer(),
          dispatch: dispatch()
        ]
      )
    ]

    Supervisor.init(children, strategy: :one_for_one, name: __MODULE__)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/game", Tetris99.Web.WebSocket, []},
         {:_, Plug.Cowboy.Handler, {Tetris99.Web.Routes, []}}
       ]}
    ]
  end
end
