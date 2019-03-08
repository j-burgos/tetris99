defmodule Tetris99.Web.Routes do
  use Plug.Router

  plug(Plug.Logger)

  plug(
    Plug.Static,
    at: "/public",
    from: {:tetris99, "priv/static/assets"}
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_file(conn, 200, "priv/static/index.html")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
