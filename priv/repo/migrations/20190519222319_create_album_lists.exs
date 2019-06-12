defmodule AlbumTags.Repo.Migrations.CreateAlbumLists do
  use Ecto.Migration

  def up do
    create table(:album_lists) do
      add :album_id, references(:albums, on_delete: :delete_all), null: false # when an album  is deleted, delete album_list record
      add :list_id, references(:lists, on_delete: :delete_all), null: false # when a list is deleted, delete album_list record
      add :user_id, references(:users, on_delete: :delete_all), null: false # when a user is deleted, delete  album_list record

      timestamps()
    end

    create index(:album_lists, [:album_id])
    create index(:album_lists, [:list_id])
    create index(:album_lists, [:user_id])

  end

  def down do
    drop table(:album_lists)
  end
end
