defmodule AlbumTagsWeb.AppleMusicView do
  use AlbumTagsWeb, :view
  alias Jason

  def render("index.json", %{albums: albums}) do
    json_albums = Jason.decode!(albums)["results"]["albums"]["data"]

    %{albums: Enum.map(json_albums, fn album -> album_json(album) end)}
  end

  def render("show.json", %{album: album}) do
    json_album = Jason.decode!(album)["data"]
    data_element = List.first(json_album)

    %{album: album_json(data_element)}
  end

  # Private

  defp isolate_song_data(all_songs) do
    Enum.map(all_songs, fn song ->
        %{
          name: song["attributes"]["name"],
          duration: milliseconds_to_time(song["attributes"]["durationInMillis"]),
          track_number: song["attributes"]["trackNumber"],
          preview: List.first(song["attributes"]["previews"])["url"]
        }
    end)
  end

  defp album_json(album) do
    songs = case album["relationships"]["tracks"]["data"] do
      nil -> nil
      _ -> isolate_song_data(album["relationships"]["tracks"]["data"])
    end

    %{
      appleAlbumID: album["id"],
      appleUrl: album["attributes"]["url"],
      title: album["attributes"]["name"],
      artist: album["attributes"]["artistName"],
      releaseDate: album["attributes"]["releaseDate"],
      recordCompany: album["attributes"]["recordLabel"],
      songs: songs,
      cover: album["attributes"]["artwork"]["url"]
    }
  end

  defp milliseconds_to_time(millis) do
    total_seconds = Integer.floor_div(millis, 1000)
    minutes = Integer.floor_div(total_seconds,  60)
    seconds = total_seconds - (minutes * 60)

    case length(Integer.digits(seconds)) < 2 do
      true  -> "#{minutes}:0#{seconds}"
      false -> "#{minutes}:#{seconds}"
    end
  end
end
