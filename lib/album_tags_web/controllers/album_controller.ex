defmodule AlbumTagsWeb.AlbumController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  def show(conn, %{"id" => apple_album_id}) do
    album = Albums.get_album_by(%{apple_album_id: apple_album_id})
    data_for_page = %{album: album, page: "album", user: conn.assigns.current_user}
    render(conn, "show.html", data_for_page)
  end
end
