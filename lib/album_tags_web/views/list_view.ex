defmodule AlbumTagsWeb.ListView do
  use AlbumTagsWeb, :view

  def render("show.json", %{message: message, new_list: new_list}) when not is_nil(new_list) do
    %{
      message: message,
      new_list: %{
        title: new_list.title,
        id: new_list.id
      }
    }
  end

  def render("show.json", %{message: message}) do
    message
  end

  def album_cover(album) do
    album.cover
    |> String.replace("{w}", "120")
    |> String.replace("{h}", "120")
  end

  def get_cover_at(albums, index) do
    case Enum.fetch(albums, index) do
      {:ok, album} ->
        album_cover(album)
      :error ->
        nil
    end
  end
end
