defmodule TrelloCloneClientWeb.Live.Board.Manage do

  use TrelloCloneClientWeb, :live_view

  alias TrelloCloneClient.API.Users

  alias TrelloCloneClient.API.BoardPermissions

  def mount(_params, session, socket) do
    {:ok, socket
          |> assign_defaults(session)}
  end


  def handle_event("invite", _params, socket) do
    socket =
      socket
      |> assign(invite: true)
    {:noreply, socket}
  end

  def handle_event("cancel_invite", _params, socket) do
    socket =
      socket
      |> assign(invite: nil)
    {:noreply, socket}
  end

  def handle_event("change_invite", %{"user_id" => user_id}, %{assigns: assigns} = socket) do
    invite_member = Enum.find(assigns.results, fn r -> r.id == user_id end)

    socket =
      socket
      |> assign(invite_member: invite_member)
      |> assign(invite: nil)
    {:noreply, socket}
  end

  def handle_event("invite_member", _params, %{assigns: assigns} = socket) do
    case assigns.invite_member do
      nil ->
        {:noreply, put_flash_message(socket, :error, "Please select a valid user")}
      invite_member ->
        params = %{
          "user_id" => invite_member.id,
          "board_id" => assigns.board.id,
          "permission_type" => :read,
          "access_token" => assigns.access_token
        }
        with {:ok, board_permission} <- BoardPermissions.create_board_permission(params) do
          board_permissions = assigns.board_permissions ++ [board_permission]
          members = assigns.members ++ [board_permission.user]
          socket =
            socket
            |> assign(board_permissions: board_permissions)
            |> assign(members: members)
            |> assign(invite: nil)
            |> assign(invite_member: nil)
            |> assign(results: nil)
            |> assign(search_query: nil)
            |> put_flash_message(:info, "Successfully invited member")
          {:noreply, socket}
          else
            _error ->
              {:noreply, put_flash_message(socket, :error, "Unable to invite member")}
        end
    end
  end

  def handle_event("search_user", %{"user" => %{"email" => email } = user} = _params, %{assigns: assigns} = socket) do
    params = Map.merge(%{"access_token" => assigns.access_token}, user)
    users =
      with {:ok, users} <- Users.search_users_by_email(params) do
        users -- (assigns.members ++ [assigns.current_user])
      else
        _ -> []
      end

    socket =
      socket
      |> assign(search_query: email)
      |> assign(results: users)

    {:noreply, socket}
  end

  def handle_event("change_permission",
      %{"permission_type" => permission_type, "permission_id" => permission_id},
      %{assigns: assigns} = socket
    ) do

    params = %{
      "access_token" => assigns.access_token,
      "id" => permission_id,
      "permission_type" => permission_type
    }

    permission = Enum.find(assigns.board_permissions, &(&1.id == permission_id))

    with {:ok, permission} <- BoardPermissions.update_board_permission(permission, params) do
      board_permissions =
        Enum.map(assigns.board_permissions, fn bp ->
          if bp.id == permission.id, do: permission, else: bp
        end)
        socket =
          socket
          |> assign(board_permissions: board_permissions)
          |> put_flash_message(:info, "Successfully updated permission")
        {:noreply, socket}
    else
      _error ->
        {:noreply, put_flash_message(socket, :error, "Unable to update permission")}
    end

  end


  def handle_event("remove_permission",
      %{"permission_id" => permission_id},
      %{assigns: assigns} = socket
    ) do

    params = %{
      "access_token" => assigns.access_token,
      "id" => permission_id,
      "board_id" => assigns.board.id
    }

    permission = Enum.find(assigns.board_permissions, &(&1.id == permission_id))

    with :ok <- BoardPermissions.delete_board_permission(params) do
      board_permissions = assigns.board_permissions -- [permission]
      members = assigns.members -- [permission.user]
        socket =
          socket
          |> assign(board_permissions: board_permissions)
          |> assign(members: members)
          |> put_flash_message(:info, "Successfully deleted permission")
        {:noreply, socket}
    else
      _error ->
        {:noreply, put_flash_message(socket, :error, "Unable to delete permission")}
    end

  end


  def handle_event("cancel", _params, socket) do
    send(socket.parent_pid, :close_modal)
    {:noreply, socket}
  end

  defp assign_defaults(socket, session) do
    board = session["board"]
    current_user = session["current_user"]
    access_token = session["access_token"]
    board_permission = session["board_permission"]

    params = %{
      "board_id" => board.id,
      "access_token" => access_token
    }

    board_permissions =
      fetch_board_members(params)
      |> Enum.reject(fn bp -> bp.user_id == current_user.id end)

    members =
      Enum.map(board_permissions, fn bp -> bp.user end)

    socket
    |> assign(current_user: current_user)
    |> assign(access_token: access_token)
    |> assign(board: board)
    |> assign(board_permission: board_permission)
    |> assign(board_permissions: board_permissions)
    |> assign(members: members)
    |> assign(flash_message: nil)
    |> assign(results: nil)
    |> assign(search_query: "")
    |> assign(invite: nil)
    |> assign(invite_member: nil)
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
