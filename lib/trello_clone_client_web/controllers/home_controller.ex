defmodule TrelloCloneClientWeb.HomeController do
  use TrelloCloneClientWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:access_token, get_session(conn, :access_token))
    |> assign(:current_user, get_session(conn, :current_user))
    |> assign(:active, "home")
    |> render("index.html")

  end

end
