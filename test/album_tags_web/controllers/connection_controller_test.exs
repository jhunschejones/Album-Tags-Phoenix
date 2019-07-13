defmodule AlbumTagsWeb.ConnectionControllerTest do
  use AlbumTagsWeb.ConnCase

  alias AlbumTags.Albums.Album
  alias AlbumTags.{Repo, Albums}

  @album_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @album_two_attrs %{apple_album_id: 1135092935, apple_url: "https://itunes.apple.com/us/album/passengers/1135092935", title: "Passengers", artist: "Artifex Pereo", release_date: "2016-09-09", record_company: "Tooth & Nail Records", cover: "https://is2-ssl.mzstatic.com/image/thumb/Music20/v4/c5/64/ce/c564ce15-0e87-458c-cbb0-9941d65b5648/886446002583.jpg/{w}x{h}bb.jpeg"}
  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}
  @alt_user_attrs %{name: "Daisy Bear", email: "daisy@dafox.com", provider: "google", token: "test token 2"}

  describe "edit/2" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      {:ok, album: album, user: user}
    end

    test "redirects for user authentication", %{conn: conn, album: album} do
      conn = get(conn, Routes.connection_path(conn, :edit, album.apple_album_id))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "serves edit page to authenticated users", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.connection_path(conn, :edit, album.apple_album_id))
      assert html_response(conn, 200) =~ ~s(<div id="connections-container" class="row">)
    end
  end

  describe "new/2" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      {:ok, album: album, user: user}
    end

    test "redirects for user authentication", %{conn: conn, album: album} do
      conn = get(conn, Routes.connection_path(conn, :new, %{"parent_album" => album.apple_album_id}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "serves edit page to authenticated users", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.connection_path(conn, :new, %{"parent_album" => album.apple_album_id}))
      assert html_response(conn, 200) =~ ~s(<div id="connection-search-container">)
    end
  end

  describe "create/2" do
    setup do
      user = user_fixture(@user_attrs)
      {:ok, user: user}
    end

    test "redirects for user authentication", %{conn: conn} do
      conn = post(conn, Routes.connection_path(conn, :create, %{"parentAlbum" => @album_attrs.apple_album_id, "childAlbum" => @album_two_attrs.apple_album_id}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "creates a connection", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.connection_path(conn, :create, %{"parentAlbum" => @album_attrs.apple_album_id, "childAlbum" => @album_two_attrs.apple_album_id}))
      album_one = Repo.get_by(Album, %{apple_album_id: @album_attrs.apple_album_id}) |> Albums.album_with_connections()
      album_two = Repo.get_by(Album, %{apple_album_id: @album_two_attrs.apple_album_id}) |> Albums.album_with_connections()

      assert response = json_response(conn, 200)
      assert response["message"] == "Connection successfully created"
      assert List.first(album_one.connections).id == album_two.id
      assert List.first(album_two.connections).id == album_one.id
    end

    test "prevents connecting an album to itself", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.connection_path(conn, :create, %{"parentAlbum" => @album_attrs.apple_album_id, "childAlbum" => @album_attrs.apple_album_id}))

      assert response = json_response(conn, 400)
      assert response["message"] == "You cannot connect an album to itself"
    end

    test "prevents duplicate connections", %{conn: conn, user: user} do
      connection_fixture(album_fixture(@album_attrs), album_fixture(@album_two_attrs), user)
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.connection_path(conn, :create, %{"parentAlbum" => @album_attrs.apple_album_id, "childAlbum" => @album_two_attrs.apple_album_id}))

      assert response = json_response(conn, 400)
      assert response["message"] == "You cannot connect two albums more than once"
    end
  end

  describe "delete/2" do
    setup do
      user = user_fixture(@user_attrs)
      album_one = album_fixture(@album_attrs)
      album_two = album_fixture(@album_two_attrs)
      connection_fixture(album_one, album_two, user)
      {:ok, user: user, album_one: album_one, album_two: album_two}
    end

    test "redirects for user authentication", %{conn: conn, album_one: album_one, album_two: album_two} do
      conn = delete(conn, Routes.connection_path(conn, :delete, 1, %{"parentAlbum" => album_one.id, "childAlbum" => album_two.id}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "deletes a connection", %{conn: conn, user: user, album_one: album_one, album_two: album_two} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = delete(conn, Routes.connection_path(conn, :delete, 1, %{"parentAlbum" => album_one.id, "childAlbum" => album_two.id}))
      album = Repo.get_by(Album, %{apple_album_id: album_one.apple_album_id}) |> Albums.album_with_connections()

      assert response = json_response(conn, 200)
      assert response == "Connection deleted"
      assert album.connections == []
    end

    test "won't remove a connection created by another user", %{conn: conn, album_one: album_one, album_two: album_two} do
      album_before = Repo.get_by(Album, %{apple_album_id: album_one.apple_album_id}) |> Albums.album_with_connections()
      conn = Plug.Test.init_test_session(conn, user_id: user_fixture(@alt_user_attrs).id)
      conn = delete(conn, Routes.connection_path(conn, :delete, 1, %{"parentAlbum" => album_one.id, "childAlbum" => album_two.id}))
      album_after = Repo.get_by(Album, %{apple_album_id: album_one.apple_album_id}) |> Albums.album_with_connections()

      assert length(album_after.connections) == 1
      assert album_before.connections == album_after.connections
      assert response = json_response(conn, 500)
      assert response == "Unable to delete connection"
    end
  end
end
