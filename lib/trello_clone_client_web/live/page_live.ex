defmodule TrelloCloneClientWeb.PageLive do
  use TrelloCloneClientWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket
          |> assign(query: "", results: %{})
          |> load_assigns(session) }
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not TrelloCloneClientWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end

  defp load_assigns(socket, session) do
    socket
    |> assign(current_user: session["current_user"])
    |> assign(access_token: session["access_token"])
  end

end
