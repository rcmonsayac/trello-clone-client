defmodule TrelloCloneClient.API.Lists do
  alias Ecto.Changeset
  alias TrelloCloneClient.Schemas.List

  @success_codes 200..399


  def all_board_lists(params) do
    url = "/api/boards/:board_id/lists"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- List.query_changeset(%List{}, params),
         query = Changeset.apply_changes(changeset),
         path_params = Map.take(query, [:board_id]),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url, opts: [path_params: path_params]) do
        {:ok, Enum.map(body, &from_response/1)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end

  end

  def get_list(params) do
    url = "/api/:board_id/lists/:id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- List.query_changeset(%List{}, params),
         query = Changeset.apply_changes(changeset),
         path_params = Map.take(query, [:board_id, :id]),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url, opts: [path_params: path_params]) do
        {:ok, from_response(body)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end

  end

  def create_list(params) do
    url = "/api/boards/:board_id/lists"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- List.create_changeset(%List{}, params),
         list = Changeset.apply_changes(changeset),
         path_params = Map.take(list, [:board_id]),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.post(client, url, list, opts: [path_params: path_params]) do
        {:ok, from_response(body)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end

  end

  def update_list(list, params) do
    url = "/api/boards/:board_id/lists/:id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- List.update_changeset(list, params),
         list = Changeset.apply_changes(changeset),
         path_params = Map.take(list, [:board_id, :id]),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.patch(client, url, list, opts: [path_params: path_params]) do
        {:ok, from_response(body)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end

  end

  def delete_list(params) do
    url = "/api/boards/:board_id/lists/:id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- List.query_changeset(%List{}, params),
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
    do: %List{} |> List.changeset(response) |> Changeset.apply_changes()

end
