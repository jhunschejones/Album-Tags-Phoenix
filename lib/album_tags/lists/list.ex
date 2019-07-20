defmodule AlbumTags.Lists.List do
  use Ecto.Schema
  import Ecto.Changeset

  @not_capitalized_words ["a", "an", "and", "the", "for", "but", "yet", "so", "nor", "at", "by", "of", "to", "on"]

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
    |> capitalize_title()
    |> unique_constraint(:title, name: :lists_title_user_id_index)
  end

  defp capitalize_title(changeset) do
    case get_field(changeset, :title) do
      nil ->
        changeset
      title ->
        clean_title = title
          |> String.trim()
          |> String.downcase()
          |> String.split()
          |> Stream.with_index()
          |> Enum.map_join(" ", fn {word, index} ->
              case index != 0 && Enum.any?(@not_capitalized_words, &(&1 == word)) do
                true -> word
                false -> String.capitalize(word)
              end
            end)

        put_change(changeset, :title, clean_title)
    end
  end
end
