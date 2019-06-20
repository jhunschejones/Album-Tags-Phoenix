defmodule AlbumTags.Albums.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :custom_genre, :boolean, default: false
    field :text, :string
    belongs_to :user, AlbumTags.Accounts.User
    many_to_many :albums, AlbumTags.Albums.Album, join_through: "album_tags"

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:text, :user_id, :custom_genre])
    |> validate_required([:text, :user_id, :custom_genre])
    |> validate_length(:text, min: 2, max: 30)
    |> unique_constraint(:text, name: :tags_text_user_id_index)
  end
end
