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

  def url_tag(tag) do
    URI.encode(tag.text)
  end

  def sort_songs(songs_map) do
    Enum.sort(songs_map, &(&1.track_number < &2.track_number))
  end

  def sortLists(lists) do
    lists
    |> Enum.sort_by(fn list -> list.title end)
  end

  def remove_duplicate_tags(tags, user) do
    if !user do
      tags
    else
      user_tags = Enum.filter(tags, &(&1.user_id == user.id))
      other_tags = Enum.filter(tags, &(&1.user_id != user.id))
      deduped_other_tags = Enum.filter(other_tags, fn tag ->
        !Enum.any?(user_tags, &(&1.text == tag.text))
      end)

      Enum.concat(user_tags, deduped_other_tags)
    end
  end

  def remove_duplicate_connections(connections, user) do
    if !user do
      connections
    else
      user_connections = Enum.filter(connections, &(&1.connection_owner == user.id))
      other_connections = Enum.filter(connections, &(&1.connection_owner != user.id))
      deduped_other_connections = Enum.filter(other_connections, fn connection ->
        !Enum.any?(user_connections, &(&1.apple_album_id == connection.apple_album_id))
      end)

      Enum.concat(user_connections, deduped_other_connections)
    end
  end
end
