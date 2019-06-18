defmodule AlbumTagsWeb.ConnectionController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  plug :authenticate_user when action in [:edit]

  # show update connections page with form
  def edit(conn, %{"id" => apple_album_id}) do
    album = Albums.get_album_with(apple_album_id, [:connections])
    data_for_page = %{album: album, page: "edit_connections", user: conn.assigns.current_user}
    render(conn, "edit.html", data_for_page)
  end

  # receive new connection input from form
  # def create(conn, %{"id" => apple_album_id} = params) do
  #   render(conn, "edit.html", page: nil)
  # end

  # # receive connection delete input from form
  # def delete(conn, %{"id" => apple_album_id} = params) do
  #   render(conn, "edit.html", page: nil)
  # end
end
