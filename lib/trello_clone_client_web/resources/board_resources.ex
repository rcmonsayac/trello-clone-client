defmodule TrelloCloneClientWeb.Resources.BoardResources do

  alias TrelloCloneClient.API.BoardPermissions

  def resource(conn, :board_permission, %{"id" => board_id}) do
    access_token = conn.assigns.access_token
    current_user = conn.assigns.current_user
    params = %{
      "access_token" => access_token,
      "user_id" => current_user.id,
      "board_id" => board_id
    }

    with {:ok, permission} <- BoardPermissions.get_board_permission(params) do
      {:ok, :board_permission, permission}
    else
      _ ->
        {:error, :board_permission}
    end
  end
end
