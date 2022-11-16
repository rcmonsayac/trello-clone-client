defmodule TrelloCloneClientWeb.ErrorHandler do
  import Plug.Conn
  use Phoenix.Controller

  def policy_error(conn, _error) do
    conn
    |> put_flash(:error, "You do not have sufficient permissions to view this page.")
    |> redirect(to: "/boards")
  end

  def resource_not_found(conn, :board_permission) do
    conn
    |> put_flash(:error, "You do not have sufficient permissions to view this page.")
    |> redirect(to: "/boards")
  end

  def resource_not_found(conn, _resource) do
    conn
    |> put_status(:not_found)
    |> put_view(TrelloCloneClientWeb.ErrorView)
    |> render("error_page.html")
    |> halt()
  end
end
