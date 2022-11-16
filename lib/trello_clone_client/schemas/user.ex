defmodule TrelloCloneClient.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias TrelloCloneClient.Schemas.Board
  alias TrelloCloneClient.Schemas.List
  alias TrelloCloneClient.Schemas.Task
  alias TrelloCloneClient.Schemas.Comment



  @derive {Jason.Encoder,
  only: [
    :id,
    :email,
    :password
  ]}

  @primary_key false
  schema "users" do
    field :id, Ecto.UUID, primary_key: true
    field :email, :string
    field :password, :string
    field :password_confirmation, :string, virtual: true
    has_many :created_boards, Board, foreign_key: :created_by_id, references: :id
    has_many :created_lists, List, foreign_key: :created_by_id, references: :id
    has_many :created_tasks, Task, foreign_key: :created_by_id, references: :id
    has_many :assigned_tasks, Task, foreign_key: :assignee_id, references: :id
    has_many :created_comments, Comment, foreign_key: :created_by_id, references: :id
    timestamps()
  end

  def changeset(user, attrs \\ %{})  do
    fields = ~w(id email)a
    user
    |> cast(attrs, fields)
    |> validate_required(fields)
  end

  def sign_in_changeset(user, attrs \\ %{}) do
    fields = ~w(email password)a
    user
    |> cast(attrs, fields)
    |> validate_required(fields)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_length(:password, min: 6)
  end

  def registration_changeset(user, attrs \\ %{}) do
    fields = ~w(email password password_confirmation)a
    user
    |> cast(attrs, fields)
    |> validate_required(fields)
    |> validate_confirmation(:password)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_length(:password, min: 6)
  end

  def query_changeset() do

  end

end
