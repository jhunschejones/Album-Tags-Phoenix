defmodule AlbumTagsWeb.AlbumView do
  use AlbumTagsWeb, :view

  def album_cover(album) do
    album.cover
    |> String.replace("{w}", "500")
    |> String.replace("{h}", "500")
  end

  def release_year(album) do
    album.release_date
    |> String.slice(0, 4)
  end

  def release_date(album) do
    year = String.slice(album.release_date, 0, 4)
    month = String.slice(album.release_date, 5, 2)
    day = String.slice(album.release_date, 8, 2)

    "#{month}/#{day}/#{year}"
  end
end
