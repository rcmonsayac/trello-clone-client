defmodule TrelloCloneClientWeb.Live.Register.Index do
  use TrelloCloneClientWeb, :live_view

  alias TrelloCloneClient.Schemas.User
  alias TrelloCloneClient.API.Users
  alias TrelloCloneClient.Auth

  def mount(_params, _session, socket) do
    {:ok, socket
          |> assign(flash_message: nil)
          |> assign(changeset: User.registration_changeset(%User{}))
    }
  end

  def handle_event("register", %{"user" => user_params}, socket) do

    with {:ok, user} <- Users.validate(user_params),
         {:ok, body} <- Auth.register(user) do
      {:noreply, redirect(socket, to: Routes.session_path(socket, :create, body))}

    else
      {:error,  %Ecto.Changeset{} = changeset  } ->
        {:noreply, assign(socket, changeset: %{changeset | action: :register})} #create error constructor
      _error ->
          {:noreply,
          socket
          |> put_flash_message(:error, "Email already taken.") #create error constructor
          |> assign(changeset: User.registration_changeset(%User{}, user_params))}
    end
  end
end
