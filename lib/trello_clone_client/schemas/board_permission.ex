defmodule TrelloCloneClient.Schemas.BoardPermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias TrelloCloneClient.Schemas.User
  alias TrelloCloneClient.Schemas.Board

  @derive {Jason.Encoder,
  only: [
    :id,
    :permission_type,
    :user_id,
    :board_id
  ]}

  @primary_key false
  schema "board_permissions" do
    field :id, Ecto.UUID, primary_key: true
    field :permission_type, TrelloCloneClient.PermissionType
    belongs_to :board, Board, foreign_key: :board_id, type: Ecto.UUID
    belongs_to :user, User, foreign_key: :user_id, type: Ecto.UUID

    timestamps()
  end

  @fields ~w(id permission_type board_id user_id)a

  @doc false
  def changeset(board_permission, attrs) do
    board_permission
    |> cast(attrs, @fields)
    |> cast_assoc(:user)
    |> validate_required(@fields)
  end

  def query_changeset(board_permission, attrs \\ %{}) do
    fields = ~w(id board_id user_id)a
    board_permission
    |> cast(attrs, fields)
  end

  def create_changeset(board_permission, attrs \\ %{}) do
    fields = ~w(permission_type board_id user_id)a

    board_permission
    |> cast(attrs, fields)
    |> validate_required(fields)
  end

  def update_changeset(board_permission, attrs \\ %{}) do
    board_permission
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end

  def delete_changeset(board_permission, attrs \\ %{}) do
    fields = ~w(id)a
    board_permission
    |> cast(attrs, fields)
    |> validate_required(fields)
  end

  defp cast_user(permission_changeset) do
    if permission_changeset.changes[:user], do: cast_assoc(permission_changeset, :user), else: permission_changeset
  end
end
