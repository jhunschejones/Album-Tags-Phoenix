defmodule AlbumTagsWeb.PageController do
  use AlbumTagsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", user: conn.assigns.current_user, page: nil)
  end
end
