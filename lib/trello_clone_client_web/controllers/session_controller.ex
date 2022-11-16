defmodule TrelloCloneClientWeb.SessionController do
  use TrelloCloneClientWeb, :controller

  alias TrelloCloneClient.Schemas.User
  alias TrelloCloneClient.Auth
  alias TrelloCloneClient.API.Users

  def new(conn, _params) do
    conn
    |> assign(:access_token, nil)
    |> assign(:current_user, nil)
    |> assign(:changeset, User.sign_in_changeset(%User{}))
    |> render("signin.html")
  end

  def signin(conn, %{"user" => user_params} = _params) do
    with {:ok, user} <- Users.validate(user_params),
         {:ok, body} <- Auth.signin(user) do
      redirect(conn, to: Routes.session_path(conn, :create, body))
    else
      {:error,  %Ecto.Changeset{} = changeset  } ->
        conn
        |> assign(:access_token, nil)
        |> assign(:current_user, nil)
        |> assign(:changeset, %{changeset | action: :signin})
        |> render("signin.html")
      _error ->
        conn
        |> assign(:access_token, nil)
        |> assign(:current_user, nil)
        |> put_flash(:error, "Email already taken.") #expand more on error handling
        |> assign(:changeset, User.sign_in_changeset(%User{}, user_params))
        |> render("signin.html")
    end
  end

  def create(conn,
    %{
      "token" => access_token,
      "user" => user
     } = _params) do

    conn = conn
    |> put_session(:access_token, access_token)
    |> put_session(:current_user, current_user(user))
    |> put_flash(:info, "Login Successful")

    redirect(conn, to: Routes.home_path(conn, :index))

  end

  def logout(conn, _params) do
    access_token = get_session(conn, :access_token)
    Auth.logout(access_token)

    conn = update_in(conn.assigns, &Map.drop(&1, [:current_user]))

    conn
    |> delete_session(:access_token)
    |> delete_session(:current_user)
    |> put_flash(:info, "Logout Successful")
    |> redirect(to: Routes.session_path(conn, :new))

  end

  defp current_user(user),
    do: %User{} |> User.changeset(user) |> Ecto.Changeset.apply_changes()

end
