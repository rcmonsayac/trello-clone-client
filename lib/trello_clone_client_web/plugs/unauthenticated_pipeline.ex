defmodule TrelloCloneClientWeb.Plugs.UnauthenticatedPipeline do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case Plug.Conn.get_session(conn, :access_token) do
      nil ->
        conn
      _access_token ->
        conn
        |> redirect(to: "/")
        |> halt()
    end
    conn
  end
end
