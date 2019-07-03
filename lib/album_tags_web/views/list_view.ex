defmodule AlbumTagsWeb.ListView do
  use AlbumTagsWeb, :view

  def render("show.json", %{message: message, new_list: new_list}) when not is_nil(new_list) do
    %{message: message, new_list: %{title: new_list.title, id: new_list.id}}
  end

  def render("show.json", %{message: message, added_album: added_album}) when not is_nil(added_album) do
    %{message: message, added_album: added_album}
  end

  def render("show.json", %{message: message, list_title: list_title}) when not is_nil(list_title) do
    %{message: message, list_title: list_title}
  end

  def render("show.json", %{message: message}) do
    message
  end

  def album_cover(album, size) do
    album.cover
    |> String.replace("{w}", size)
    |> String.replace("{h}", size)
  end

  def get_cover_at(albums, index) do
    case Enum.fetch(albums, index) do
      {:ok, album} ->
        album_cover(album, "120")
      :error ->
        nil
    end
  end

  def sort_albums(albums) do
    albums
    |> Enum.sort(&(&1.release_date >= &2.release_date))
  end

  def sort_lists(lists) do
    lists
    |> Enum.sort_by(fn list -> list.title end)
  end
end
