defmodule AlbumTagsWeb.AppleMusicController do
  use AlbumTagsWeb, :controller
  alias HTTPotion

  def search(conn, %{"search_string" => search_string, "offset" => offset}) do
    # default offset is 0, pass in a different value for more pages of results
    apple_response = HTTPotion.get("https://api.music.apple.com/v1/catalog/us/search?term=#{search_string}&offset=#{offset || 0}&limit=25&types=artists,albums", headers: [Accept: "application/json", Authorization: "Bearer XXXXXX"])

    render(conn, "index.json", albums: apple_response.body)
  end

  def details(conn, %{"id" => album_id}) do
    apple_response = HTTPotion.get("https://api.music.apple.com/v1/catalog/us/albums/#{album_id}", headers: [Accept: "application/json", Authorization: "Bearer XXXXXX"])

    render(conn, "show.json", album: apple_response.body)
  end
end
