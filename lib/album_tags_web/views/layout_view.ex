defmodule AlbumTagsWeb.LayoutView do
  use AlbumTagsWeb, :view

  def favorites_id(conn) do
    Plug.Conn.get_session(conn, :favorites_list_id)
  end
end
