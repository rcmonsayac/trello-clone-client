defmodule TrelloCloneClientWeb.Live.Board.Index do
  use TrelloCloneClientWeb, :live_view
  alias TrelloCloneClient.API.Boards

  def mount(_params, session, socket) do
    params = %{"access_token" => session["access_token"]}
    {:ok, socket
          |> assign(flash_message: nil)
          |> assign_defaults(session)
          |> fetch_boards(params)}
  end

  def handle_event("open_modal", _params, socket) do
    {:noreply,
    socket
    |> assign(create_modal: true)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, create_modal: nil)}
  end

  def handle_info(:close_modal, socket) do
    {:noreply, push_event(socket, "close_modal", %{})}
  end

  defp fetch_boards(socket, params) do
    with {:ok, boards} <- Boards.all_boards(params) do
      assign(socket, boards: boards)
    else
      _error ->
        socket
        |> assign(boards: %{})
        |> put_flash_message(:error, "Unable to fetch boards")
    end
  end

  defp assign_defaults(socket, session) do
    socket
    |> assign(current_user: session["current_user"])
    |> assign(access_token: session["access_token"])
    |> assign(create_modal: nil)
  end
end
