defmodule AlbumTagsWeb.TagController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  plug :authenticate_user when action in [:edit]

  # show all tags
  def index(conn, _params) do
    all_tags = Albums.list_tags()
    render(conn, "index.html", tags: all_tags, page: nil)
  end

  # show update tags page with form
  def edit(conn, %{"id" => apple_album_id}) do
    album = Albums.get_album_with(apple_album_id, [:tags])
    data_for_page = %{album: album, page: "edit_tags", user: conn.assigns.current_user}
    render(conn, "edit.html", data_for_page)
  end

  # receive new tag input from form
  # def create(conn, %{"id" => apple_album_id} = params) do
  #   render(conn, "edit.html", page: nil)
  # end

  # # receive tag delete input from form
  # def delete(conn, %{"id" => apple_album_id} = params) do
  #   render(conn, "edit.html", page: nil)
  # end
end
