defmodule AlbumTagsWeb.ListView do
  use AlbumTagsWeb, :view

  def render("show.json", %{message: message}) do
    message
  end
end
