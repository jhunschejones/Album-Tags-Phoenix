defmodule AlbumTagsWeb.ListControllerTest do
  use AlbumTagsWeb.ConnCase

  # alias AlbumTags.Albums.List
  # alias AlbumTags.{Repo, Albums, Lists}

  @album_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}
  # @alt_user_attrs %{name: "Daisy Bear", email: "daisy@dafox.com", provider: "google", token: "test token 2"}

  describe "index/2" do
    test "redirects for user authentication", %{conn: conn} do
      conn = get(conn, Routes.list_path(conn, :index))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "serves my-lists page to authenticated users", %{conn: conn} do
      user = user_fixture(@user_attrs)
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.list_path(conn, :index))
      assert html_response(conn, 200) =~ ~s(<div id="new-list-modal" class="modal">)
    end
  end

  describe "show/2" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      list = list_fixture(%{title: "Test List", user_id: user.id, album_id: album.id})
      {:ok, user: user, list: list}
    end

    test "serves list page without edit functionality to un-authenticated users", %{conn: conn, list: list} do
      conn = get(conn, Routes.list_path(conn, :show, list.id))
      assert html_response(conn, 200) =~ ~s(div id="listVueApp">)
      refute html_response(conn, 200) =~ ~s(<div id="edit-list-modal" class="modal">)
    end

    test "serves list page with edit functionality to authenticated users", %{conn: conn, list: list, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.list_path(conn, :show, list.id))
      assert html_response(conn, 200) =~ ~s(div id="listVueApp">)
      assert html_response(conn, 200) =~ ~s(<div id="edit-list-modal" class="modal">)
    end
  end

  describe "edit/2" do
    setup do
      album = album_fixture(@album_attrs)
      {:ok, album: album}
    end

    test "redirects for user authentication", %{conn: conn, album: album} do
      conn = get(conn, Routes.list_path(conn, :edit, album.apple_album_id))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "serves edit page to authenticated users", %{conn: conn, album: album} do
      user = user_fixture(@user_attrs)
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.list_path(conn, :edit, album.apple_album_id))
      assert html_response(conn, 200) =~ ~s(<div id="lists-container">)
      assert html_response(conn, 200) =~ ~s(<i class="large material-icons">arrow_back</i>)
    end
  end
end
