defmodule TrelloCloneClientWeb.LiveComponents.ListComponent do
  use TrelloCloneClientWeb, :live_component

  alias TrelloCloneClient.API.Lists

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(edit_list_id: nil)}
  end

  def render(assigns), do: Phoenix.View.render(TrelloCloneClientWeb.ListView, "list.html", assigns)

  def handle_event("update_list_title", %{"list" => list_params} =_params, socket) do

    params = Map.merge(%{"access_token" => socket.assigns.access_token}, list_params)

    with {:ok, list} <- Lists.update_list(socket.assigns.list, params) do
      send(self(), {:update, :success, list})
      socket =
        socket
        |> assign(edit_list_id: nil)
        |> assign(list: list)
      {:noreply, socket}
    else
      _error ->
        send(self(), {:update, :error})
        {:noreply, socket} #expand more on error handling
    end
  end

  def handle_event("edit_title", %{"list_id" => list_id}, socket) do
    {:noreply, assign(socket, edit_list_id: list_id)}
  end

  def handle_event("cancel_edit_title", _params, socket) do
    {:noreply, assign(socket, edit_list_id: nil)}
  end

end
