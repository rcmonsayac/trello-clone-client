defmodule TrelloCloneClientWeb.Live.SignIn.Index do
  use TrelloCloneClientWeb, :live_view

  alias TrelloCloneClient.Schemas.User
  alias TrelloCloneClient.API.Users
  alias TrelloCloneClient.Auth

  def mount(_params, _session, socket) do
    {:ok, socket
          |> assign(flash_message: nil)
          |> assign(changeset: User.sign_in_changeset(%User{}))
    }
  end

  def handle_event("signin", %{"user" => user_params}, socket) do

    with {:ok, user} <- Users.validate(user_params),
         {:ok, body} <- Auth.signin(user) do
      {:noreply, redirect(socket, to: Routes.session_path(socket, :create, body))}

    else
      {:error,  %Ecto.Changeset{} = changeset  } ->
        {:noreply, assign(socket, changeset: %{changeset | action: :signin})}
      _error ->
          {:noreply,
          socket
          |> put_flash_message(:error, "Invalid credentials") #expand more on error handling
          |> assign(changeset: User.sign_in_changeset(%User{}, user_params))}
    end

  end


end
