defmodule AlbumTags.Repo.Migrations.CreateAlbumConnections do
  use Ecto.Migration

  def up do
    create table(:album_connections) do
      add :parent_album, :integer
      add :child_album, :integer
      add :user_id, :integer

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
