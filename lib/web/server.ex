defmodule Tetris99.Web.Server do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_init_args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Tetris99.Web.Routes,
        options: [
          port: 5000,
          timeout: 60000 * 3,
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
