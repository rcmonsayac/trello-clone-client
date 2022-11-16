defmodule TrelloCloneClient.Schemas.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  alias TrelloCloneClient.Schemas.User
  alias TrelloCloneClient.Schemas.Task

  @derive {Jason.Encoder,
  only: [
    :id,
    :content,
    :task_id,
    :created_by_id,
    :inserted_at
  ]}

  @primary_key false
  schema "comments" do
    field :id, Ecto.UUID, primary_key: true
    field :content, :string
    belongs_to :created_by_user, User, foreign_key: :created_by_id, type: Ecto.UUID
    belongs_to :task, Task, type: Ecto.UUID
    timestamps()
  end

  @fields ~w(id content created_by_id task_id)a

  @doc false
  def changeset(comment, attrs) do
    fields = @fields ++ [:inserted_at]
    comment
    |> cast(attrs, fields)
    |> cast_assoc(:created_by_user)
    |> validate_required(fields)
  end

  def query_changeset(comment, attrs \\ %{}) do
    fields = ~w(id task_id)a
    comment
    |> cast(attrs, fields)
  end

  def create_changeset(comment, attrs \\ %{}) do
    fields = ~w(content task_id)a
    comment
    |> cast(attrs, fields)
    |> validate_required(fields)
  end

  def update_changeset(comment, attrs \\ %{}) do
    comment
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  def delete_changeset(comment, attrs \\ %{}) do
    fields = ~w(id)a
    comment
    |> cast(attrs, fields)
    |> validate_required(fields)
  end

end
