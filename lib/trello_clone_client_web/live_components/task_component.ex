defmodule TrelloCloneClientWeb.LiveComponents.TaskComponent do
  use TrelloCloneClientWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def render(assigns), do: Phoenix.View.render(TrelloCloneClientWeb.TaskView, "task_card.html", assigns)


end
