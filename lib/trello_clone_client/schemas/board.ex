defmodule TrelloCloneClient.Schemas.Board do
  use Ecto.Schema
  import Ecto.Changeset

  alias TrelloCloneClient.Schemas.User
  alias TrelloCloneClient.Schemas.List
  alias TrelloCloneClient.Schemas.Task

  @derive {Jason.Encoder,
  only: [
    :id,
    :title,
    :description,
    :created_by_id
  ]}

  @primary_key false
  schema "boards" do
    field :id, Ecto.UUID, primary_key: true
    field :description, :string
    field :title, :string
    belongs_to :created_by_user, User, foreign_key: :created_by_id, type: Ecto.UUID
    has_many :lists, List, foreign_key: :board_id, references: :id
    has_many :tasks, Task, foreign_key: :board_id, references: :id
    timestamps()
  end

  @fields ~w(id description title created_by_id)a

  @doc false
  def changeset(board, attrs \\ %{}) do
    board
    |> cast(attrs, @fields)
    |> cast_assoc(:lists)
    |> cast_assoc(:tasks)
    |> validate_required(@fields)

  end

  def query_changeset(board, attrs \\ %{}) do
    fields = ~w(id)a
    board
    |> cast(attrs, fields)
    |> validate_required(fields)
  end

  def create_changeset(board, attrs \\ %{}) do
    fields = ~w(description title)a

    board
    |> cast(attrs, fields)
    |> validate_required(fields)
  end
end
