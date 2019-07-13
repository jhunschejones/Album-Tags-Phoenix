defmodule AlbumTagsWeb.AlbumControllerTest do
  use AlbumTagsWeb.ConnCase

  @album_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}

  describe "show/2" do
    test "returns the album page when user is authenticated", %{conn: conn} do
      conn = Plug.Test.init_test_session(conn, user_id: user_fixture(@user_attrs).id)
      conn = get(conn, Routes.album_path(conn, :show, album_fixture(@album_attrs).apple_album_id))
      assert html_response(conn, 200) =~ "<h6 id=\"title\">The Question</h6>"
    end

    test "returns the album page when user is not authenticated", %{conn: conn} do
      conn = get(conn, Routes.album_path(conn, :show, album_fixture(@album_attrs).apple_album_id))
      assert html_response(conn, 200) =~ "<h6 id=\"title\">The Question</h6>"
    end
  end
end
