defmodule TrelloCloneClient.Schemas.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias TrelloCloneClient.Schemas.User
  alias TrelloCloneClient.Schemas.Board
  alias TrelloCloneClient.Schemas.List
  alias TrelloCloneClient.Schemas.Comment


  @derive {Jason.Encoder,
  only: [
    :id,
    :title,
    :description,
    :list_id,
    :board_id,
    :position,
    :assignee_id,
    :created_by_id,
    :status
  ]}

  @primary_key false
  schema "tasks" do
    field :id, Ecto.UUID, primary_key: true
    field :description, :string
    field :position, :decimal
    field :title, :string
    field :status, TrelloCloneClient.TaskStatus
    belongs_to :created_by_user, User, foreign_key: :created_by_id, type: Ecto.UUID
    belongs_to :assignee_user, User, foreign_key: :assignee_id, type: Ecto.UUID
    belongs_to :list, List, type: Ecto.UUID
    belongs_to :board, Board, type: Ecto.UUID
    has_many :comments, Comment, foreign_key: :task_id, references: :id
    timestamps()
  end


  @fields ~w(
    id
    title
    description
    position
    status
    list_id
    board_id
    assignee_id
    created_by_id
    )a

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, @fields)
    |> cast_assignee
    |> validate_required(@fields)
  end

  def query_changeset(task, attrs \\ %{}) do
    fields = ~w(id list_id board_id)a
    task
    |> cast(attrs, fields)
  end

  def create_changeset(task, attrs \\ %{}) do
    fields = ~w(
      title
      description
      status
      list_id
      board_id
      assignee_id
      )a

    required = ~w(
      title
      status
      list_id
      board_id
      )a

    task
    |> cast(attrs, fields)
    |> validate_required(required)
  end

  def update_changeset(task, attrs \\ %{}) do

    required = ~w(
      id
      title
      status
      position
      created_by_id
      list_id
      board_id
      )a

    task
    |> cast(attrs, @fields)
    |> validate_required(required)
  end


  def delete_changeset(list, attrs \\ %{}) do
    fields = ~w(id)a
    list
    |> cast(attrs, fields)
    |> validate_required(fields)
  end

  defp cast_assignee(task_changeset) do
    if task_changeset.changes[:assignee_id], do: cast_assoc(task_changeset, :assignee_user), else: task_changeset
  end

end
