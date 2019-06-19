defmodule AlbumTags.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def up do
    create table(:albums) do
      add :apple_album_id, :integer
      add :apple_url, :string
      add :title, :string
      add :artist, :string
      add :release_date, :string
      add :record_company, :string
      add :cover, :string

      timestamps()
    end

    create index(:albums, [:apple_album_id], unique: true)
  end

  def down do
    drop table(:albums)
  end
end
