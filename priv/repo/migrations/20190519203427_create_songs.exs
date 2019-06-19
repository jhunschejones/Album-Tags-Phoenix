defmodule AlbumTags.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def up do
    create table(:songs) do
      add :name, :string
      add :duration, :string
      add :album_id, references(:albums, on_delete: :delete_all), null: false # delete all asociated songs wne an album is deleted
      add :preview, :string
      add :track_number, :integer
    end

    create index(:songs, [:album_id])
    create index(:songs, [:name, :album_id, :track_number], unique: true)
  end

  def down do
    drop table(:songs)
  end
end
