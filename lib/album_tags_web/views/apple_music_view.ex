defmodule AlbumTagsWeb.AppleMusicView do
  use AlbumTagsWeb, :view
  alias Jason

  def render("index.json", %{albums: albums}) do
    %{albums: albums
        |> Jason.decode!
        |> Map.get("results")
        |> Map.get("albums")
        |> Map.get("data")
        |> Enum.map(&album_json &1)
    }
  end

  def render("show.json", %{album: album}) do
    %{album: album
        |> Jason.decode!
        |> Map.get("data")
        |> List.first
        |> album_json
    }
  end

  # Private

  defp isolate_song_data(all_songs) when is_nil(all_songs), do: nil

  defp isolate_song_data(all_songs) do
    all_songs
    |> Enum.map(fn song ->
      %{
        name: song["attributes"]["name"],
        duration: milliseconds_to_time(song["attributes"]["durationInMillis"]),
        track_number: song["attributes"]["trackNumber"],
        preview: List.first(song["attributes"]["previews"])["url"]
      } end)
  end

  defp album_json(album) do
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
