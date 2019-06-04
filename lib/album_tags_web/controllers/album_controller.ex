defmodule AlbumTagsWeb.AlbumController do
  use AlbumTagsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
