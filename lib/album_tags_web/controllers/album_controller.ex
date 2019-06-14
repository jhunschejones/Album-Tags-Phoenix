defmodule AlbumTagsWeb.AlbumController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  def show(conn, %{"id" => apple_album_id}) do
    album = Albums.get_album_by(%{apple_album_id: apple_album_id})
    render(conn, "show.html", album: album, page: "album")
  end
end
