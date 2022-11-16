defmodule TrelloCloneClientWeb.ViewHelpers do
  import Phoenix.HTML.Tag
  import Phoenix.LiveView, only: [assign: 3]


  def put_flash_message(socket, type, message) do
    assign(socket, :flash_message, {Atom.to_string(type), message, :rand.uniform(1_000)})
  end

  @valid_flash_kinds ["success", "info", "warning", "error"]

  def render_live_flash({type, message, rand}),
  do:
    content_tag(
      :div,
      "",
      phx_hook: "LiveFlash",
      id: "live-flash",
      class: "_hidden",
      data: [
        flash_type: type,
        flash_message: message,
        rand: rand,
        liveview: true
      ]
    )


  def render_live_flash(_flash),
    do: content_tag(:div, "", id: "live-flash", class: "_hidden", phx_hook: "LiveFlash")

  def hash(data, alg \\ :sha256) do
    str = "#{inspect(data)}"
    binary = :crypto.hash(alg, str)

    Base.encode16(binary, padding: false)
  end

  def sort(resources),
    do: Enum.sort(resources, &(Decimal.compare(&1.position, &2.position) in [:eq, :lt]))

  def sort(resources, :inserted_at),
    do: Enum.sort(resources, &(NaiveDateTime.compare(&1.inserted_at, &2.inserted_at) in [:eq, :lt]))

  def get_list_tasks(tasks, list_id) do
    Enum.filter(tasks, fn t -> t.list_id == list_id end)
  end

  def task_status,
    do: [
      "not_started",
      "in_progress",
      "for_review",
      "blocked",
      "done"
    ]

  @status_to_label %{
    "not_started" => "Not Started",
    "in_progress" => "In Progress",
    "for_review" => "For Review",
    "blocked" => "Blocked",
    "done" => "Done"
  }

  def status_to_label(status) when not is_atom(status), do: @status_to_label[status]
  def status_to_label(status) when is_atom(status), do: @status_to_label[Atom.to_string(status)]

def board_permission_types,
  do: [
    "manage",
    "write",
    "read"
  ]

@permission_to_label %{
  "manage" => "Manage",
  "read" => "Read",
  "write" => "Write"
}

def permission_to_label(permission) when not is_atom(permission), do: @permission_to_label[permission]
def permission_to_label(permission) when is_atom(permission), do: @permission_to_label[Atom.to_string(permission)]

end
