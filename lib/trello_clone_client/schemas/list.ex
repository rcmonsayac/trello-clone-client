defmodule TrelloCloneClient.Schemas.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias TrelloCloneClient.Schemas.User
  alias TrelloCloneClient.Schemas.Board
  alias TrelloCloneClient.Schemas.Task


  @derive {Jason.Encoder,
  only: [
    :id,
    :title,
    :board_id,
    :position,
    :created_by_id
  ]}

  @primary_key false
  schema "lists" do
    field :id, Ecto.UUID, primary_key: true
    field :position, :decimal
    field :title, :string
    belongs_to :board, Board, foreign_key: :board_id, type: Ecto.UUID
    belongs_to :created_by_user, User, foreign_key: :created_by_id, type: Ecto.UUID
    has_many :tasks, Task, foreign_key: :list_id, references: :id
    timestamps()
  end

  @doc false

  @fields ~w(id board_id title position created_by_id)a

  def changeset(list, attrs) do
    list
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  def query_changeset(list, attrs \\ %{}) do
    fields = ~w(id board_id)a
    list
    |> cast(attrs, fields)
  end

  def create_changeset(list, attrs \\ %{}) do
    fields= ~w(board_id title)a
    list
    |> cast(attrs, fields)
    |> validate_required(fields)
  end

  def update_changeset(list, attrs \\ %{}) do
    list
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  def delete_changeset(list, attrs \\ %{}) do
    fields = ~w(id)a
    list
    |> cast(attrs, fields)
    |> validate_required(fields)
  end


end
