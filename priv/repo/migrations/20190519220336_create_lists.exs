defmodule AlbumTags.Repo.Migrations.CreateLists do
  use Ecto.Migration

  def up do
    create table(:lists) do
      add :title, :string
      add :private, :boolean, default: false, null: false
      add :permalink, :string
      add :user_id, :integer

      timestamps()
    end

    create index(:lists, [:user_id])
    create index(:lists, [:permalink])
  end

  def down do
    drop table(:lists)
  end
end
