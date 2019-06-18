defmodule AlbumTagsWeb.AppleMusicController do
  use AlbumTagsWeb, :controller
  alias HTTPotion

  # /api/apple/search/?search_string=emery&offset=0
  def search(conn, %{"search_string" => search_string, "offset" => offset}) do
    apple_response = HTTPotion.get("https://api.music.apple.com/v1/catalog/us/search?term=#{search_string}&offset=#{offset || 0}&limit=25&types=artists,albums", headers: [Accept: "application/json", Authorization: "Bearer #{System.get_env("APPLE_MUSIC_TOKEN")}"])

    render(conn, "index.json", albums: apple_response.body)
  end

  def details(conn, %{"id" => album_id}) do
    apple_response = HTTPotion.get("https://api.music.apple.com/v1/catalog/us/albums/#{album_id}", headers: [Accept: "application/json", Authorization: "Bearer #{System.get_env("APPLE_MUSIC_TOKEN")}"])

    render(conn, "show.json", album: apple_response.body)
  end
end
