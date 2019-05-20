defmodule AlbumTagsWeb.AppleMusicView do
  use AlbumTagsWeb, :view
  alias Jason

  def render("index.json", %{albums: albums}) do
    %{albums: Enum.map(albums, &album_json/1)}
  end

  def render("show.json", %{album: album}) do
    # IO.inspect Jason.decode!(album)["data"]
    # %{album: Jason.decode!(album)["data"]}
    json_album = Jason.decode!(album)["data"]
    data_element = List.first(json_album)

    %{album: album_json(data_element)}
  end

  def isolate_song_data(all_songs) do
    Enum.map(all_songs, fn x ->
        %{
          name: x["attributes"]["name"],
          duration: milliseconds_to_time(x["attributes"]["durationInMillis"]),
          track_number: x["attributes"]["trackNumber"],
          preview: List.first(x["attributes"]["previews"])["url"]
        }
    end)
  end

  def album_json(album) do
    %{
      appleAlbumID: album["id"],
      appleUrl: album["attributes"]["url"],
      title: album["attributes"]["name"],
      artist: album["attributes"]["artistName"],
      releaseDate: album["attributes"]["releaseDate"],
      recordCompany: album["attributes"]["recordLabel"],
      songs: isolate_song_data(album["relationships"]["tracks"]["data"]),
      cover: album["attributes"]["artwork"]["url"]
    }
  end

  def milliseconds_to_time(millis) do
    total_seconds = Integer.floor_div(millis, 1000)
    minutes = Integer.floor_div(total_seconds,  60)
    seconds = total_seconds - (minutes * 60)

    case length(Integer.digits(seconds)) < 2 do
      true  -> "#{minutes}:0#{seconds}"
      false -> "#{minutes}:#{seconds}"
    end
  end
end
