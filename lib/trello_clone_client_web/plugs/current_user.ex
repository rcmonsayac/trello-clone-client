defmodule TrelloCloneClientWeb.Plugs.CurrentUser do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case Plug.Conn.get_session(conn, :current_user) do
      nil ->
        conn
        |> redirect(to: "/signin")
        |> halt()

      current_user ->
        conn
        |> assign(:current_user, current_user)
    end
  end

end
