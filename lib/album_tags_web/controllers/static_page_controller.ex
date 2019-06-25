defmodule AlbumTagsWeb.StaticPageController do
  use AlbumTagsWeb, :controller

  def home(conn, _params) do
    render(conn, "index.html", user: conn.assigns.current_user, page: "home")
  end
end
