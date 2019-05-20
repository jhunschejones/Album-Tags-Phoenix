defmodule AlbumTags.Albums.AlbumTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "album_tags" do
    belongs_to :album, AlbumTags.Albums.Album
    belongs_to :tag, AlbumTags.Albums.Tag
    belongs_to :user, AlbumTags.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:album_id, :tag_id, :user_id])
    |> validate_required([:album_id, :tag_id, :user_id])
  end
end
