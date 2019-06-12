defmodule AlbumTags.Albums.Album do
  use Ecto.Schema
  import Ecto.Changeset

  schema "albums" do
    field :apple_album_id, :integer
    field :apple_url, :string
    field :artist, :string
    field :cover, :string
    field :record_company, :string
    field :release_date, :string
    field :title, :string
    has_many :songs, AlbumTags.Albums.Song
    many_to_many :tags, AlbumTags.Albums.Tag, join_through: "album_tags"
    many_to_many :lists, AlbumTags.Lists.List, join_through: "album_lists"

    timestamps()
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:apple_album_id, :apple_url, :title, :artist, :release_date, :record_company, :cover])
    |> validate_required([:apple_album_id, :apple_url, :title, :artist, :release_date, :record_company, :cover])
  end
end
