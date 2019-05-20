defmodule AlbumTags.Lists.AlbumList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "album_lists" do
    belongs_to :album, AlbumTags.Albums.Album
    belongs_to :list, AlbumTags.Lists.List
    belongs_to :user, AlbumTags.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:album_id, :list_id, :user_id])
    |> validate_required([:album_id, :list_id, :user_id])
  end
end
