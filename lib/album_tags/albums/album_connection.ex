defmodule AlbumTags.Albums.AlbumConnection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "album_connections" do
    field :parent_album, :integer
    field :child_album, :integer
    belongs_to :user, AlbumTags.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:parent_album, :child_album, :user_id])
    |> validate_required([:parent_album, :child_album, :user_id])
  end
end
