defmodule AlbumTagsWeb.MigrationController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.{Albums, Lists}

  def create_album(conn, params \\ %{}) do
    album = Albums.find_or_create_album(params["apple_album_id"])
    render(conn, "response.json", message: "The route works!", album_id: album.id)
  end

  def add_tag(conn, %{"text" => text, "user_id" => user_id, "album_id" => album_id}) do
    {:ok, tag} = Albums.find_or_create_tag(%{text: text, user_id: user_id, custom_genre: false})

    response = case Albums.add_tag_to_album(%{
      album_id: album_id,
      user_id: user_id,
      tag_id: tag.id
    }) do
      {:ok, _} ->
        "new tag added"
      {:error, %{errors: [text: {"has already been taken", [constraint: :unique, constraint_name: "album_tags_album_id_tag_id_user_id_index"]}]}} ->
        "tag already exists"
    end
    render(conn, "response.json", message: response)
  end

  def add_connection(conn, %{"parent_album" => parent_album, "child_album" => child_album, "user_id" => user_id}) do
    album = Albums.get_album_with(parent_album, [:connections])
    child = Albums.find_or_create_album(child_album)
    connections = Enum.map(album.connections, &(&1.id))

    response = case Enum.member?(connections, child.id) do
      true ->
        "already connected"
      false ->
        Albums.create_album_connection(%{parent_album: album.id, child_album: child.id, user_id: user_id})
        "albums connected"
    end

    render(conn, "response.json", message: response)
  end

  def create_list(conn, %{"title" => title, "user_id" => user_id, "albums" => albums}) do
    case Lists.create_list(%{
      title: force_title_case(title),
      private: false,
      user_id: user_id,
    }) do
      {:ok, list} ->
        Enum.each(albums, fn album ->
          Lists.add_album_to_list(%{
            album_id: Albums.find_or_create_album(album).id,
            list_id: list.id,
            user_id: user_id,
          })
        end)
      {:error, %{errors: [title: {"has already been taken", [constraint: :unique, constraint_name: "lists_title_user_id_index"]}]}} ->
        list = Lists.get_list_by(%{title: force_title_case(title), user_id: user_id})
        Enum.each(albums, fn album ->
          Lists.add_album_to_list(%{
            album_id: Albums.find_or_create_album(album).id,
            list_id: list.id,
            user_id: user_id,
          })
        end)
    end

    render(conn, "response.json", message: "It worked?")
  end

  defp force_title_case(input_string) do
    not_capitalized = ["a", "an", "and", "the", "for", "but", "yet", "so", "nor", "at", "by", "of", "to", "on"]

    input_string
    |> String.trim()
    |> String.downcase()
    |> String.split()
    |> Enum.with_index()
    |> Enum.map_join(" ", fn {word, index} ->
        word_not_capitalizable = Enum.any?(not_capitalized, &(&1 == word))
        case index != 0 && word_not_capitalizable do
          true -> word
          false -> String.capitalize(word)
        end
      end)
  end
end
