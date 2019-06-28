defmodule AlbumTags.Albums.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:text, :user_id]}
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
    |> validatate_allowed_characters(:text)
    |> unique_constraint(:text, name: :tags_text_user_id_index)
  end

  def validatate_allowed_characters(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn field, value ->
      case String.contains?(value, [",,", "{", "}"]) do
        false -> []
        true -> [{field, "disallowed character used"}]
      end
    end)
  end
end
