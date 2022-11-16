defmodule TrelloCloneClientWeb.Live.Task.Show do
  use TrelloCloneClientWeb, :live_view

  alias TrelloCloneClient.API.Tasks
  alias TrelloCloneClient.API.Users
  alias TrelloCloneClient.API.Comments
  alias TrelloCloneClient.API.BoardPermissions
  alias TrelloCloneClient.Schemas.Comment


  def mount(_params, session, socket) do
    {:ok, socket
          |> assign_defaults(session)}
  end

  def handle_event("change_status", %{"status" => task_status}, %{assigns: assigns} = socket) do
    params = %{
      "access_token" => assigns.access_token,
      "status" => task_status
    }

    with {:ok, task} <- Tasks.update_task(assigns.current_task, params) do
      send(socket.parent_pid, {:task_updated, task})
      socket =
        socket
        |> assign(current_task: task)
        |> assign(task_status: task_status)
        |> put_flash_message(:info, "Task status updated successfully")
      {:noreply, socket}
    else
      _error ->
        {:noreply,
        socket
        |> put_flash_message(:error, "Unable to update task status")} #expand more on error handling
    end
  end

  def handle_event("edit_task", %{"field" => field}, socket) when field != "assignee" do
    socket =
      socket
      |> assign(results: nil)
      |> assign(edit_task: field)
    {:noreply, socket}
  end

  def handle_event("edit_task", %{"field" => "assignee"}, %{assigns: assigns} = socket) do
    socket =
      socket
      |> assign(search_query: (if assigns.assignee, do: assigns.assignee.email, else: ""))
      |> assign(edit_task: "assignee")
    {:noreply, socket}
  end

  def handle_event("cancel_edit", _params, socket) do
    socket =
      socket
      |> assign(results: nil)
      |> assign(edit_task: nil)
    {:noreply, socket}
  end

  def handle_event("update_task", %{"task" => task_params}, %{assigns: assigns} = socket) do
    params = Map.merge(%{"access_token" => assigns.access_token}, task_params)

    with {:ok, task} <- Tasks.update_task(assigns.current_task, params) do
      send(socket.parent_pid, {:task_updated, task})
      socket =
        socket
        |> assign(edit_task: nil)
        |> assign(current_task: task)
        |> put_flash_message(:info, "Task updated successfully")
      {:noreply, socket}
    else
      _error ->
        {:noreply,
        socket
        |> put_flash_message(:error, "Unable to update task.")} #expand more on error handling
    end
  end

  def handle_event("update_task", %{"assignee_id" => _assignee_id} = params, %{assigns: assigns} = socket) do
    params = Map.merge(%{"access_token" => assigns.access_token}, params)

    with {:ok, task} <- Tasks.update_task(assigns.current_task, params) do
      send(socket.parent_pid, {:task_updated, task})
      socket =
        socket
        |> assign(edit_task: nil)
        |> assign(current_task: task)
        |> assign(assignee: task.assignee_user)
        |> put_flash_message(:info, "Task updated successfully")
      {:noreply, socket}
    else
      _error ->
        {:noreply,
        socket
        |> put_flash_message(:error, "Unable to update task.")} #expand more on error handling
    end
  end

  def handle_event("update_task", %{"unassign" => "true"}, %{assigns: assigns} = socket) do
    params = %{
      "access_token" => assigns.access_token,
      "assignee_id" => nil
    }

    with {:ok, task} <- Tasks.update_task(assigns.current_task, params) do
      send(socket.parent_pid, {:task_updated, task})
      socket =
        socket
        |> assign(edit_task: nil)
        |> assign(current_task: task)
        |> assign(assignee: nil)
        |> put_flash_message(:info, "Task updated successfully")
      {:noreply, socket}
    else
      _error ->
        {:noreply,
        socket
        |> put_flash_message(:error, "Unable to update task.")} #expand more on error handling
    end
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

  def handle_event("delete_task", _params, %{assigns: assigns} = socket) do
    params =
      %{
        "access_token" => socket.assigns.access_token,
        "id" => assigns.current_task.id,
        "board_id" => assigns.current_task.board_id
      }

    with :ok <- Tasks.delete_task(params) do
      send(socket.parent_pid, {:task_deleted, assigns.current_task})
      send(socket.parent_pid, :close_modal)
      {:noreply, socket}
    else
      _error ->
        {:noreply,
        socket
        |> put_flash_message(:error, "Unable to delete task.")} #expand more on error handling
    end
  end

  def handle_event("change_view", %{"view" => view}, socket) do
    {:noreply, assign(socket, view: view)}
  end

  def handle_event("add_comment", _params, socket) do
    socket =
      socket
      |> assign(comment_changeset: Comment.create_changeset(%Comment{}))
      |> assign(add_comment: true)
    {:noreply, assign(socket, add_comment: true)}
  end

  def handle_event("cancel_add_comment", _params, socket) do
    socket =
      socket
      |> assign(add_comment: nil)
    {:noreply, socket}
   end

  def handle_event("update_comment_changeset", %{"comment" => comment_params}, socket) do
    {:noreply, assign(socket, comment_changeset: Comment.create_changeset(%Comment{}, comment_params))}
  end

  def handle_event("create_comment", %{"comment" => comment_params}, %{assigns: assigns} = socket) do
    params = Map.merge(%{"access_token" => socket.assigns.access_token}, comment_params)

    with {:ok, comment} <- Comments.create_comment(params) do
      comments = assigns.comments ++ [comment]
      socket =
        socket
        |> assign(add_comment: nil)
        |> assign(comments: comments)
        |> put_flash_message(:info, "Comment added successfully ")
      {:noreply, socket}
    else
      {:error,  %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, comment_changeset: %{changeset | action: :create})}
      _error ->
        {:noreply,
        socket
        |> put_flash_message(:error, "Unable to add comment") #expand more on error handling
        |> assign(comment_changeset: Comment.create_changeset(%Comment{}, comment_params))}
    end
  end


  def handle_event("cancel", _params, socket) do
    send(socket.parent_pid, :close_modal)
    {:noreply, socket}
  end

  defp assign_defaults(socket, session) do
    access_token = session["access_token"]
    task = session["current_task"]
    board_permission = session["board_permission"]
    current_user = session["current_user"]
    board_id = session["board_id"]

    comment_params  = %{
      "access_token" => access_token,
      "task_id" => task.id
    }
    comments = fetch_comments(comment_params)

    members_params = %{
      "access_token" => access_token,
      "board_id" => board_id
    }

    board_permissions =  fetch_board_members(members_params)
    members =
      Enum.map(board_permissions, fn bp -> bp.user end)

    assignee = if task.assignee_id, do: task.assignee_user, else: nil

    socket
    |> assign(current_user: current_user)
    |> assign(access_token: access_token)
    |> assign(current_task: task)
    |> assign(assignee: assignee)
    |> assign(board_permission: board_permission)
    |> assign(members: members)
    |> assign(change_assignee: nil)
    |> assign(task_status: task.status)
    |> assign(edit_task: nil)
    |> assign(results: nil)
    |> assign(search_query: "")
    |> assign(add_comment: nil)
    |> assign(comments: comments)
    |> assign(comment_changeset: Comment.create_changeset(%Comment{}))
    |> assign(flash_message: nil)
    |> assign(view: "details")
  end

  defp fetch_comments(params) do
    with {:ok, comments} <- Comments.all_task_comments(params) do
      comments
    else
      _ -> []
    end
  end

  defp fetch_board_members(params) do
    with {:ok, board_permissions} <- BoardPermissions.get_board_members(params) do
      board_permissions
    else
      _ -> []
    end
  end

end
