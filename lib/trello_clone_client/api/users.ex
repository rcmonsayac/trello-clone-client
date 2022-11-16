defmodule TrelloCloneClient.API.Users do
  alias Ecto.Changeset

  alias TrelloCloneClient.Schemas.User

  @success_codes 200..399

  def validate(%{"password_confirmation" => _password} = params) do
    with %{valid?: true} = changeset <- User.registration_changeset(%User{}, params),
         user = Changeset.apply_changes(changeset) do
      {:ok, user}
    else
      %Changeset{} = changeset -> {:error, changeset}
      error -> error
    end
  end

  def validate(params) do
    with %{valid?: true} = changeset <- User.sign_in_changeset(%User{}, params),
         user = Changeset.apply_changes(changeset) do
      {:ok, user}
    else
      %Changeset{} = changeset -> {:error, changeset}
      error -> error
    end
  end


  def search_users_by_email(params) do
    url = "/api/users/search"
    {access_token, params} = Map.pop(params, "access_token")


    with query_params = Map.take(params, ["email"]) ,
        client = client(access_token),
        {:ok, %{body: body, status: status}} when status in @success_codes <-
          Tesla.get(client, url, query: query_params) do
      {:ok, Enum.map(body, &from_response/1)}
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
    do: %User{} |> User.changeset(response) |> Changeset.apply_changes()

end
