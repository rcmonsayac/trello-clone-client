defmodule TrelloCloneClient.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards) do

      timestamps()
    end

  end
end
