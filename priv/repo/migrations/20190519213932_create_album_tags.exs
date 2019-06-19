defmodule AlbumTags.Repo.Migrations.CreateAlbumTags do
  use Ecto.Migration

  def up do
    create table(:album_tags) do
      # when an album, associated tag, or user is fully deleted, delete album_tags join table record
      add :album_id, references(:albums, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:album_tags, [:album_id])
    create index(:album_tags, [:tag_id])
    create index(:album_tags, [:user_id])
    create index(:album_tags, [:album_id, :tag_id, :user_id], unique: true)
  end

  def down do
    drop table(:album_tags)
  end
end
