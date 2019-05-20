defmodule AlbumTagsWeb.AppleMusicController do
  use AlbumTagsWeb, :controller
  alias HTTPotion

  # def search(conn, _params) do
  #
  # end

  def details(conn, %{"id" => album_id}) do
    apple_response = HTTPotion.get("https://api.music.apple.com/v1/catalog/us/albums/#{album_id}", headers: [Accept: "application/json", Authorization: "Bearer XXXXXX"])

    render conn, "show.json", album: apple_response.body
  end
end
