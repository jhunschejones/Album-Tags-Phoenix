defmodule AlbumTags.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def up do
    create table(:tags) do
      add :text, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false # delete tags when a user is deleted
      add :custom_genre, :boolean, default: false, null: false

      timestamps()
    end

    create index(:tags, [:user_id])
    create index(:tags, [:text])

  end

  def down do
    drop table(:tags)
  end
end
