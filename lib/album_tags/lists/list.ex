defmodule AlbumTags.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :permalink, :string
    field :private, :boolean, default: false
    field :title, :string
    belongs_to :user, AlbumTags.Accounts.User
    many_to_many :albums, AlbumTags.Albums.Album, join_through: "album_lists"

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :private, :permalink, :user_id])
    |> validate_required([:title, :private, :permalink, :user_id])
    |> validate_length(:title, min: 2, max: 60)
    |> unique_constraint(:title, name: :lists_title_user_id_index)
  end
end
