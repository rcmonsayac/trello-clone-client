defmodule TrelloCloneClientWeb.Live.Board.Show do
  use TrelloCloneClientWeb, :live_view

  alias TrelloCloneClient.API.Lists
  alias TrelloCloneClient.API.Tasks

  @topic "board"

  def mount(_params, session, socket) do
    board_id = session["board"].id
    topic_ident = "#{@topic}:#{board_id}"
    Phoenix.PubSub.subscribe(TrelloCloneClient.PubSub, topic_ident)

    socket = assign(socket, current_topic: topic_ident) |> assign_defaults(session)

    {:ok, socket}
  end

  def handle_event("add_list", _params, socket) do
    {:noreply, assign(socket, modal: :list_form)}
  end

  def handle_event("add_task", %{"list_id" => list_id}, %{assigns: assigns} = socket) do
    list = Enum.find(assigns.lists, &(&1.id == list_id))
    socket =
      socket
      |> assign(current_list: list)
      |> assign(modal: :task_form)

    {:noreply, socket}
  end

  def handle_event("close_modal", _params, socket) do
    socket =
      socket
      |> assign(modal: nil)
      |> assign(current_task: nil)
      |> assign(currrent_list: nil)
    {:noreply, socket}
  end

  def handle_event("delete", %{"list_id" => list_id}, socket) do
    list = Enum.find(socket.assigns.lists, &(&1.id == list_id))
    params =
      %{
        "access_token" => socket.assigns.access_token,
        "id" => list_id,
        "board_id" => socket.assigns.board.id
      }

    with :ok <- Lists.delete_list(params) do
      lists = socket.assigns.lists -- [list]
      socket =
        socket
        |> assign(lists: lists)
        |> put_flash_message(:info, "List deleted successfully")
      {:noreply, socket}
    else
      _error ->
        {:noreply, put_flash_message(socket, :error, "Unable to delete list.")} #expand more on error handling
    end
  end

  def handle_event(
        "reorder",
        %{"type" => "list", "resourceId" => list_id, "position" => position},
        %{assigns: assigns} = socket
      ) do

    params = %{
      "access_token" => assigns.access_token,
      "position" => position
    }

    list = Enum.find(assigns.lists, &(&1.id == list_id))

    with {:ok, list} <- Lists.update_list(list, params) do
      lists =
        Enum.map(assigns.lists, fn l ->
          if l.id == list.id, do: list, else: l
        end)

      socket =
        socket
        |> put_flash_message(:info, "Lists reordered successfully")
        |> assign(modal: nil)
        |> assign(lists: lists)
      {:noreply, socket}
    else
      _error ->
        {:noreply, put_flash_message(socket, :error, "Unable to reorder list.")} #expand more on error handling
    end

  end

  def handle_event(
        "reorder",
        %{"type" => "task", "resourceId" => task_id, "position" => position, "sortableListId" => list_id},
        %{assigns: assigns} = socket
      ) do

    params = %{
      "access_token" => assigns.access_token,
      "list_id" => list_id,
      "position" => position
    }

    task = Enum.find(assigns.tasks, &(&1.id == task_id))
    with {:ok, task} <- Tasks.update_task(task, params) do
      tasks =
        Enum.map(assigns.tasks, fn t ->
          if t.id == task.id, do: task, else: t
        end)

      socket =
        socket
        |> put_flash_message(:info, "Task reordered successfully")
        |> assign(modal: nil)
        |> assign(tasks: tasks)
      {:noreply, socket}
    else
      _error ->
        {:noreply, put_flash_message(socket, :error, "Unable to reorder task.")} #expand more on error handling
    end
  end

  def handle_event("show_task", %{"task_id" => task_id} =_params, socket) do
    task = Enum.find(socket.assigns.tasks, &(&1.id == task_id))
    socket =
      socket
      |> assign(current_task: task)
      |> assign(modal: :show_task)
    {:noreply, socket}
  end

  def handle_event("manage_members", _params, %{assigns: _assigns} = socket) do
    socket =
      socket
      |> assign(modal: :manage_members)

    {:noreply, socket}
  end

  def handle_info(:close_modal, socket) do
    {:noreply, push_event(socket, "close_modal", %{})}
  end

  def handle_info({:created, list}, socket) do
    lists = socket.assigns.lists ++ [list]
    socket =
      socket
      |> assign(lists: lists)
    {:noreply, socket}
  end

  def handle_info({:task_created, task}, socket) do
    tasks = socket.assigns.tasks ++ [task]
    socket =
      socket
      |> assign(tasks: tasks)

    Phoenix.PubSub.broadcast(TrelloCloneClient.PubSub, socket.assigns.current_topic, {:task_created, task})

    {:noreply, socket}
  end

  def handle_info({:task_updated, task}, socket) do
    tasks =
      Enum.map(socket.assigns.tasks, fn t ->
        if t.id == task.id, do: task, else: t
      end)

    socket =
      socket
      |> assign(tasks: tasks)
    {:noreply, socket}
  end

  def handle_info({:task_deleted, task}, socket) do
    tasks = socket.assigns.tasks -- [task]
    socket =
      socket
      |> put_flash_message(:info, "Task deleted successfully")
      |> assign(tasks: tasks)
    {:noreply, socket}
  end

  def handle_info({:update, :success, list}, socket) do
    lists =
      Enum.map(socket.assigns.lists, fn l ->
        if l.id == list.id, do: list, else: l
      end)

    socket =
      socket
      |> put_flash_message(:info, "List title updated successfully ")
      |> assign(lists: lists)

    {:noreply, socket}
  end

  def handle_info({:update, :error}, socket) do
    socket =
      socket
      |> put_flash_message(:error, "Unable to update list title")

    {:noreply, socket}
  end

  def handle_info(%{topic: topic, payload: payload} = message, socket) do
    IO.inspect payload
    {:noreply, socket}
  end

  defp assign_defaults(socket, session) do
    board = session["board"]
    current_user = session["current_user"]
    access_token = session["access_token"]
    board_permission = session["board_permission"]
    params = %{
      "access_token" => access_token,
      "board_id" => board.id
    }

    lists = fetch_lists(params)
    tasks = fetch_tasks(params)

    socket
    |> assign(current_user: current_user)
    |> assign(access_token: access_token)
    |> assign(board_permission: board_permission)
    |> assign(board: board)
    |> assign(lists: lists)
    |> assign(tasks: tasks)
    |> assign(flash_message: nil)
    |> assign(modal: nil)
    |> assign(current_list: nil)
    |> assign(current_task: nil)
  end


  defp fetch_lists(params) do
      with {:ok, lists} <- Lists.all_board_lists(params) do
        lists
      else
        _ -> []
      end
  end

  def fetch_tasks(params) do
      with {:ok, tasks} <- Tasks.all_board_tasks(params) do
        tasks
      else
        _ -> []
      end
  end

end
