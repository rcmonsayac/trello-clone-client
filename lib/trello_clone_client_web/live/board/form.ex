defmodule TrelloCloneClientWeb.Live.Board.Form do

  use TrelloCloneClientWeb, :live_view
  alias TrelloCloneClient.API.Boards
  alias TrelloCloneClient.Schemas.Board

  def mount(_params, session, socket) do
    {:ok, socket
          |> assign_defaults(session)}
  end

  def handle_event("create", %{"board" => board_params}, socket) do

    params = Map.merge(%{"access_token" => socket.assigns.access_token}, board_params)

    with {:ok, board} <- Boards.create_board(params) do
      socket = put_flash(socket, :info, "Board created successfully!")
      {:noreply, redirect(socket, to: Routes.board_path(socket, :show, board.id))}
    else
      {:error,  %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: %{changeset | action: :create})}
      _error ->
        {:noreply,
        socket
        |> put_flash_message(:error, "Unable to create board.") #expand more on error handling
        |> assign(changeset: Board.create_changeset(%Board{}, board_params))}
    end

  end

  def handle_event("cancel", _params, socket) do
    send(socket.parent_pid, :close_modal)
    {:noreply, socket}
  end

  defp assign_defaults(socket, session) do
    socket
    |> assign(current_user: session["current_user"])
    |> assign(access_token: session["access_token"])
    |> assign(flash_message: nil)
    |> assign(changeset: Board.create_changeset(%Board{}))
  end

end
