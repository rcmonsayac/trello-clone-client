defmodule TrelloCloneClient.API.Comments do
  alias Ecto.Changeset
  alias TrelloCloneClient.Schemas.Comment


  @success_codes 200..399


  def all_task_comments(params) do
    url = "/api/tasks/:task_id/comments"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- Comment.query_changeset(%Comment{}, params),
         query = Changeset.apply_changes(changeset),
         path_params = Map.take(query, [:task_id]),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url, opts: [path_params: path_params]) do
        {:ok, Enum.map(body, &from_response/1)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end

  end

  def get_comment(params) do
    url = "/api/comments/:id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- Comment.query_changeset(%Comment{}, params),
         query = Changeset.apply_changes(changeset),
         path_params = Map.take(query, [:id]),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url, opts: [path_params: path_params]) do
        {:ok, from_response(body)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end

  end

  def create_comment(params) do
    url = "/api/comments"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- Comment.create_changeset(%Comment{}, params),
         comment = Changeset.apply_changes(changeset),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.post(client, url, comment) do
        {:ok, from_response(body)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end

  end

  def update_comment(comment, params) do
    url = "/api/comments/:id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- Comment.update_changeset(comment, params),
         comment = Changeset.apply_changes(changeset),
         path_params = Map.take(comment, [:id]),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.patch(client, url, comment, opts: [path_params: path_params]) do
        {:ok, from_response(body)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end

  end

  def delete_comment(params) do
    url = "/api/comments/:id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- Comment.query_changeset(%Comment{}, params),
         query = Changeset.apply_changes(changeset),
         path_params = Map.take(query, [:id]),
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
    do: %Comment{} |> Comment.changeset(response) |> Changeset.apply_changes()

end
