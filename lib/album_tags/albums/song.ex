defmodule AlbumTags.Albums.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :duration, :string
    field :track_number, :integer
    field :name, :string
    field :preview, :string
    belongs_to :album, AlbumTags.Albums.Album
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:duration, :track_number, :album_id, :name, :preview])
    |> validate_required([:duration, :track_number, :album_id, :name, :preview])
  end
end
