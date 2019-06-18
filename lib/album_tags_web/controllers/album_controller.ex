defmodule AlbumTagsWeb.AlbumController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  plug :authenticate_user when action in [:show]

  def show(conn, %{"id" => apple_album_id}) do
    album = Albums.get_album_with(apple_album_id)
    data_for_page = %{album: album, page: "album", user: conn.assigns.current_user}
    render(conn, "show.html", data_for_page)
  end
end
