defmodule AlbumTags.Repo.Migrations.CreateAlbumTags do
  use Ecto.Migration

  def up do
    create table(:album_tags) do
      add :album_id, :integer
      add :tag_id, :integer
      add :user_id, :integer

      timestamps()
    end

    create index(:album_tags, [:album_id])
    create index(:album_tags, [:tag_id])
    create index(:album_tags, [:user_id])

  end

  def down do
    drop table(:album_tags)
  end
end
