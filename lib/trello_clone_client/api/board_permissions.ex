defmodule TrelloCloneClient.API.BoardPermissions do
  alias Ecto.Changeset
  alias TrelloCloneClient.Schemas.BoardPermission

  @success_codes 200..399

  def get_board_permission(params) do
    url = "/api/board_permissions/:board_id/user/:user_id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset = BoardPermission.query_changeset(%BoardPermission{}, params),
        query = Changeset.apply_changes(changeset),
        client = client(access_token),
        path_params = Map.take(query, [:board_id, :user_id]),
        {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url, opts: [path_params: path_params]) do
      {:ok, from_response(body)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  def get_board_members(params) do
    url = "/api/boards/:board_id/members"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset = BoardPermission.query_changeset(%BoardPermission{}, params),
        query = Changeset.apply_changes(changeset),
        client = client(access_token),
        path_params = Map.take(query, [:board_id]),
        {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url, opts: [path_params: path_params]) do
      {:ok, Enum.map(body , &from_response/1)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  def create_board_permission(params) do
    url = "/api/boards/:board_id/board_permissions"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- BoardPermission.create_changeset(%BoardPermission{}, params),
         permission = Changeset.apply_changes(changeset),
         path_params = Map.take(permission, [:board_id]),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.post(client, url, permission, opts: [path_params: path_params]) do
        {:ok, from_response(body)}
    else
      %Changeset{} = changeset -> {:error, changeset}
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  def update_board_permission(permission, params) do
    url = "/api/boards/:board_id/board_permissions/:id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- BoardPermission.update_changeset(permission, params),
         permission = Changeset.apply_changes(changeset),
         path_params = Map.take(permission, [:board_id, :id]),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.patch(client, url, permission, opts: [path_params: path_params]) do
        {:ok, from_response(body)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  def delete_board_permission(params) do
    url = "/api/boards/:board_id/board_permissions/:id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- BoardPermission.query_changeset(%BoardPermission{}, params),
         query = Changeset.apply_changes(changeset),
         path_params = Map.take(query, [:board_id, :id]),
         client = client(access_token),
         {:ok, %{body: _body, status: status}} when status in @success_codes <-
          Tesla.delete(client, url, opts: [path_params: path_params]) do
        :ok
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  defp client(access_token) do
    url = Application.get_env(:trello_clone_client, :backend_url)

    middlewares = [
      {Tesla.Middleware.BaseUrl, url},
      Tesla.Middleware.JSON,
      Tesla.Middleware.PathParams,
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{access_token}"}]},
      Tesla.Middleware.Logger
    ]

    Tesla.client(middlewares)
  end

  defp from_response(response),
  do: %BoardPermission{} |> BoardPermission.changeset(response) |> Changeset.apply_changes()

end
