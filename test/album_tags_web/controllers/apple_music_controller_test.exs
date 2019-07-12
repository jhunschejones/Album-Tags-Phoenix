defmodule AlbumTagsWeb.AppleMusicControllerTest do
  use AlbumTagsWeb.ConnCase, async: true

  @album_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @alt_album_attrs %{apple_album_id: 1436085762, title: "This Too Won't Pass", artist: "Can't Swim", record_company: "Pure Noise Records"}

  describe "search/2" do
    test "returns a list of albums with expected data format", %{conn: conn} do
      conn = get(conn, Routes.apple_music_path(conn, :search, %{"search_string" => @album_attrs.title, "offset" => 0}))
      assert response = json_response(conn, 200)
      first_album = List.first(response["albums"])

      assert first_album["appleAlbumID"] != nil
      assert first_album["appleUrl"] != nil
      assert first_album["artist"] != nil
      assert first_album["cover"] != nil
      assert first_album["recordCompany"] != nil
      assert first_album["releaseDate"] != nil
      assert first_album["songs"] == nil # no songs are loaded for search results
      assert first_album["title"] != nil
    end

    test "returns albums that match expected search results", %{conn: conn} do
      conn = get(conn, Routes.apple_music_path(conn, :search, %{"search_string" => @album_attrs.title, "offset" => 0}))
      assert response = json_response(conn, 200)
      assert Enum.any?(response["albums"], &(&1["artist"] == @album_attrs.artist))
      assert Enum.any?(response["albums"], &(&1["recordCompany"] == @album_attrs.record_company))
    end

    test "accepts punctuation in search string", %{conn: conn} do
      conn = get(conn, Routes.apple_music_path(conn, :search, %{"search_string" => @alt_album_attrs.artist, "offset" => 0}))
      assert response = json_response(conn, 200)
      assert Enum.any?(response["albums"], &(&1["title"] == @alt_album_attrs.title))
      assert Enum.any?(response["albums"], &(&1["recordCompany"] == @alt_album_attrs.record_company))
    end
  end

  describe "details/2" do
    test "returns expected album", %{conn: conn} do
      conn = get(conn, Routes.apple_music_path(conn, :details, @album_attrs.apple_album_id))

      assert response = json_response(conn, 200)
      assert response["album"]["title"] == @album_attrs.title
      assert response["album"]["artist"] == @album_attrs.artist
    end
  end
end
