defmodule TrelloCloneClientWeb.BoardController do
  use TrelloCloneClientWeb, :controller
  alias TrelloCloneClient.API.Boards
  alias TrelloCloneClientWeb.Policies
  alias TrelloCloneClientWeb.Resources

  plug(Resources, :board_permission when action in [:show])
  plug(Policies, :read_board when action in [:show])

  def index(conn, _params) do
    conn
    |> assign(:active, "board")
    |> render("index.html")

  end

  def show(%{assigns: assigns} = conn, %{"id" => _board_id} = params) do
    access_token = get_session(conn, :access_token)

    params = Map.merge(%{"access_token" => access_token}, params)

    with {:ok, board} <- Boards.get_board(params) do
      conn
      |> assign(:board, board)
      |> assign(:board_permission, assigns.board_permission)
      |> assign(:active, "board")
      |> render("show.html")
    else
      _error ->
        conn = conn
        |> put_flash(:error, "Unable to find board")
        redirect(conn, to: Routes.board_path(conn, :index))
    end
  end


end
