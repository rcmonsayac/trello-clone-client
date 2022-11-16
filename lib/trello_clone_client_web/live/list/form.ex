defmodule TrelloCloneClientWeb.Live.List.Form do

  use TrelloCloneClientWeb, :live_view
  alias TrelloCloneClient.API.Lists
  alias TrelloCloneClient.Schemas.List

  def mount(_params, session, socket) do
    {:ok, socket
          |> assign_defaults(session)}
  end

  def handle_event("create", %{"list" => list_params}, socket) do
    params = Map.merge(%{"access_token" => socket.assigns.access_token}, list_params)

    with {:ok, list} <- Lists.create_list(params) do
      send(socket.parent_pid, {:created, list})
      send(socket.parent_pid, :close_modal)
      {:noreply,
      socket
      |> put_flash_message(:info, "List created successfully ")}
    else
      {:error,  %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: %{changeset | action: :create})}
      _error ->
        {:noreply,
        socket
        |> put_flash_message(:error, "Unable to create list.") #expand more on error handling
        |> assign(changeset: List.create_changeset(%List{}, list_params))}
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
    |> assign(board_id: session["board_id"])
    |> assign(changeset: List.create_changeset(%List{}))
    |> assign(flash_message: nil)
  end

end
