defmodule TrelloCloneClientWeb.LayoutView do
  use TrelloCloneClientWeb, :view

  def render_flash(conn) do
    conn
    |> get_flash
    |> render_flash_template
  end

  defp render_flash_template(%{"info" => content}),
    do: render("flash_success.html", title: content)

  defp render_flash_template(%{"error" => content}),
    do: render("flash_error.html", title: content)

  defp render_flash_template(_flash), do: nil
end
