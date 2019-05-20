defmodule AlbumTags.Repo.Migrations.CreateAlbumLists do
  use Ecto.Migration

  def up do
    create table(:album_lists) do
      add :album_id, :integer
      add :list_id, :integer
      add :user_id, :integer

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
