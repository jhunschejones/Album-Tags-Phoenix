defmodule AlbumTags.Repo.Migrations.CreateAlbumConnections do
  use Ecto.Migration

  def up do
    create table(:album_connections) do
      add :parent_album, references(:albums, on_delete: :delete_all), null: false # when an album is deleted, delete connection record
      add :child_album, references(:albums, on_delete: :delete_all), null: false # when an album is deleted, delete connection record
      add :user_id, references(:users, on_delete: :delete_all), null: false # when a user is deleted, delete connection record

      timestamps()
    end

    create index(:album_connections, [:parent_album])
    create index(:album_connections, [:child_album])
    create index(:album_connections, [:user_id])

  end

  def down do
    drop table(:album_connections)
  end
end
