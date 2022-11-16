defmodule TrelloCloneClientWeb.Plugs.AuthenticatedPipeline do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case Plug.Conn.get_session(conn, :access_token) do
      nil ->
        conn
        |> redirect(to: "/signin")
        |> halt()

      access_token ->
        conn
        |> assign(:access_token, access_token)
    end
  end

end
