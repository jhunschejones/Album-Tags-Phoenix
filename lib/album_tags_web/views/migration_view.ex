defmodule AlbumTagsWeb.MigrationView do
  use AlbumTagsWeb, :view

  def render("response.json", %{message: message, album_id: album_id}) do
    %{message: message, album_id: album_id}
  end

  def render("response.json", %{message: message}) do
    message
  end
end
