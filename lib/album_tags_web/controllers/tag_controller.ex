defmodule AlbumTagsWeb.TagController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  plug :authenticate_user when action in [:edit]

  def index(conn, _params) do
    all_tags = Albums.list_tags()
    render(conn, "index.html", tags: all_tags, page: nil)
  end

  def edit(conn, %{"id" => apple_album_id}) do
    album = Albums.get_album_with(apple_album_id, [:tags])
    data_for_page = %{album: album, page: "edit_tags", user: conn.assigns.current_user}
    render(conn, "edit.html", data_for_page)
  end

  def create(conn, %{"album" => apple_album_id, "tag" => text, "customGenre" => custom_genre}) do
    tag_params = %{
      text: text, user_id: conn.assigns.current_user.id, custom_genre: custom_genre
    }

    {status, message, tag_id} =
      case Albums.find_or_create_tag(tag_params) do
        {:ok, tag} ->
          case Albums.add_tag_to_album(%{
            album_id: Albums.find_or_create_album(apple_album_id).id,
            tag_id: tag.id,
            user_id: conn.assigns.current_user.id
          }) do
            {:ok, %Albums.AlbumTag{tag_id: tag_id}} ->
              {:ok, "Tag successfully created", tag_id}
            {:error, _} ->
              {:internal_server_error, "Unable to create tag", nil}
          end
        {:error, response} ->
          handle_changeset_error(response)
      end

    render(Plug.Conn.put_status(conn, status), "show.json", message: message, tag_id: tag_id)
  end

  def delete(conn, %{"albumID" => album_id, "id" => tag_id}) do
    Albums.remove_tag_from_album(%{
      album_id: album_id,
      tag_id: String.to_integer(tag_id),
      user_id: conn.assigns.current_user.id
    })
    render(conn, "show.json", message: "Tag deleted")
  end

  # return format {server_status, client_message, tag_id}
  defp handle_changeset_error(response) do
    {element, {reason, _}} = List.first(response.errors)
    case {element, reason} do
      {:text, "should be at least %{count} character(s)"} ->
        {:bad_request, "Tags must be at least two characters long", nil}
      {:text, "can't be blank"} ->
        {:bad_request, "Tags must be at least two characters long", nil}
      {:text, "should be at most %{count} character(s)"} ->
        {:bad_request, "Tags cannot be more than thirty characters long", nil}
      _ ->
        {:internal_server_error, "Unable to create connection", nil}
    end
  end
end
