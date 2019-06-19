defmodule AlbumTags.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :provider, :string
      add :token, :string
      add :profile_image, :string

      timestamps()
    end

    create index(:users, [:email], unique: true)
  end

  def down do
    drop table(:users)
  end
end
