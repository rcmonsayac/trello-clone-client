defmodule TrelloCloneClient.Auth do

  @success_codes 200..399

  def signin(user) do
    url = "/api/signin"

    with client <- client(),
         {:ok, %{body: body, status: status}} when status in @success_codes <-
           Tesla.post(client, url, user) do
      {:ok, body}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  def register(user) do
    url = "/api/register"
    with client <- client(),
      {:ok, %{body: body, status: status}} when status in @success_codes <-
        Tesla.post(client, url, user) do
      {:ok, body}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  def logout(access_token) do
    url = "/api/logout"
    with client <- client(access_token),
      {:ok, %{body: body, status: status}} when status in @success_codes <-
        Tesla.post(client, url, "") do
      {:ok, body}
    else
      {:ok, %{body: body}} -> {:error, body}
      error -> error
    end
  end

  defp client() do
    url = Application.get_env(:trello_clone_client, :backend_url)

    middlewares = [
      {Tesla.Middleware.BaseUrl, url},
      Tesla.Middleware.JSON,
      Tesla.Middleware.PathParams,
      {Tesla.Middleware.Headers, []},
      Tesla.Middleware.Logger
    ]

    Tesla.client(middlewares)
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
end
