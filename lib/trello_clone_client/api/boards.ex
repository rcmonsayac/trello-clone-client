defmodule TrelloCloneClient.API.Boards do
  alias Ecto.Changeset
  alias TrelloCloneClient.Schemas.Board

  @success_codes 200..399

  def all_boards(params) do
    url = "/api/boards"
    {access_token, _params} = Map.pop(params, "access_token")

    with client = client(access_token),
        {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url) do
      {:ok, Enum.map(body, &from_response/1)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end

  end

  def get_board(params) do
    url = "/api/boards/:id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset = Board.query_changeset(%Board{}, params),
        query = Changeset.apply_changes(changeset),
        client = client(access_token),
        path_params = Map.take(query, [:id]),
        {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url, opts: [path_params: path_params]) do
      {:ok, from_response(body)}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  def create_board(params) do
    url = "/api/boards"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset <- Board.create_changeset(%Board{}, params),
         board = Changeset.apply_changes(changeset),
         client = client(access_token),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.post(client, url, board) do
        {:ok, from_response(body)}
    else
      %Changeset{} = changeset -> {:error, changeset}
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  def get_board_permission(params) do
    url = "/api/board_permissions/:board_id/user/:user_id"
    {access_token, params} = Map.pop(params, "access_token")

    with %{valid?: true} = changeset = Board.query_changeset(%Board{}, params),
        query = Changeset.apply_changes(changeset),
        client = client(access_token),
        path_params = Map.take(query, [:id]),
        {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url, opts: [path_params: path_params]) do
      {:ok, from_response(body)}
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
  do: %Board{} |> Board.changeset(response) |> Changeset.apply_changes()

end
