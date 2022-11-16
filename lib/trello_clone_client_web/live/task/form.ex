defmodule TrelloCloneClientWeb.Live.Task.Form do

  use TrelloCloneClientWeb, :live_view
  alias TrelloCloneClient.API.Tasks
  alias TrelloCloneClient.API.Users
  alias TrelloCloneClient.API.BoardPermissions
  alias TrelloCloneClient.Schemas.Task

  def mount(_params, session, socket) do
    {:ok, socket
          |> assign_defaults(session)}
  end

  def handle_event("create", %{"task" => task_params}, %{assigns: assigns} = socket) do

    params = Map.merge(%{
      "access_token" => assigns.access_token,
      "status" => assigns.task_status,
      "assignee_id" => (if assigns.assignee, do: assigns.assignee.id, else: nil)
      }, task_params)

    with {:ok, task} <- Tasks.create_task(params) do
      send(socket.parent_pid, {:task_created, task})
      send(socket.parent_pid, :close_modal)
      {:noreply, put_flash_message(socket, :info, "Task created successfully ")}
    else
      {:error,  %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: %{changeset | action: :create})}
      _error ->
        {:noreply,
        socket
        |> put_flash_message(:error, "Unable to create task.") #expand more on error handling
        |> assign(changeset: Task.create_changeset(%Task{}, task_params))}
    end
  end

  def handle_event("cancel", _params, socket) do
    send(socket.parent_pid, :close_modal)
    {:noreply, socket}
  end

  def handle_event("change_status", %{"status" => task_status}, socket) do
    {:noreply, assign(socket, task_status: task_status)}
  end

  def handle_event("change_assignee", _params, %{assigns: assigns} = socket) do
    socket =
      socket
      |> assign(results: nil)
      |> assign(search_query: (if assigns.assignee, do: assigns.assignee.email, else: ""))
      |> assign(edit_assignee: true)
    {:noreply, socket}
  end

  def handle_event("cancel_change_assignee", _params, socket) do
    {:noreply, assign(socket, edit_assignee: nil)}
  end

  def handle_event("update_assignee", %{"assignee_id" => assignee_id} = _params, %{assigns: assigns} = socket) do

    user = Enum.find(assigns.results, &(&1.id == assignee_id))

    socket =
      socket
      |> assign(assignee: user)
      {:noreply, socket}
  end

  def handle_event("update_assignee", %{"unassign" => "true"}, socket) do
    {:noreply, assign(socket, assignee: nil)}
  end

  def handle_event("update_changeset", %{"task" => task_params}, socket) do
    {:noreply, assign(socket, changeset: Task.create_changeset(%Task{}, task_params))}
  end

  def handle_event("search_user", %{"user" => %{"email" => email } = _user} = _params, %{assigns: assigns} = socket) do

    users =
      Enum.filter(assigns.members,
        fn m ->
          String.contains?(m.email, email)
        end)

    socket =
      socket
      |> assign(search_query: email)
      |> assign(results: users)

    {:noreply, socket}
  end

  defp assign_defaults(socket, session) do
    board_id = session["board_id"]
    current_user = session["current_user"]
    access_token = session["access_token"]
    board_permission = session["board_permission"]

    params = %{
      "board_id" => board_id,
      "access_token" => access_token
    }

    board_permissions =  fetch_board_members(params)
    members =
      Enum.map(board_permissions, fn bp -> bp.user end)

    socket
    |> assign(current_user: current_user)
    |> assign(access_token: access_token)
    |> assign(board_id: board_id)
    |> assign(current_list: session["current_list"])
    |> assign(task_status: "not_started")
    |> assign(board_permission: board_permission)
    |> assign(members: members)
    |> assign(assignee: nil)
    |> assign(edit_assignee: nil)
    |> assign(search_query: nil)
    |> assign(results: nil)
    |> assign(changeset: Task.create_changeset(%Task{}))
    |> assign(flash_message: nil)
  end

  defp fetch_board_members(params) do
    with {:ok, board_permissions} <- BoardPermissions.get_board_members(params) do
      board_permissions
    else
      _ -> []
    end
  end

end
