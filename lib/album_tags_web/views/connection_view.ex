defmodule AlbumTagsWeb.ConnectionView do
  use AlbumTagsWeb, :view

  def render("show.json", %{message: message}) do
    message
  end

  def album_cover(album) do
    album.cover
    |> String.replace("{w}", "200")
    |> String.replace("{h}", "200")
  end

  def user_only(connections, user_id) do
    Enum.filter(connections, &(&1.connection_owner == user_id))
  end
end
