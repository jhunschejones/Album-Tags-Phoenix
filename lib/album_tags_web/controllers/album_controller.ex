defmodule AlbumTagsWeb.AlbumController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  def show(conn, %{"id" => apple_album_id}) do
    case Albums.get_album_with(apple_album_id) do
      {:error, nil} ->
        conn
        |> put_status(:not_found)
        |> put_view(AlbumTagsWeb.ErrorView)
        |> render("404.html", %{page: "error"})
      album ->
        data_for_page = %{album: album, page: "album", user: conn.assigns.current_user}
        render(conn, "show.html", data_for_page)
    end
  end
end
