defmodule AlbumTagsWeb.TagControllerTest do
  use AlbumTagsWeb.ConnCase, async: true

  alias AlbumTags.Albums.{Album, Tag}
  alias AlbumTags.Repo

  @album_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}
  @alt_user_attrs %{name: "Daisy Bear", email: "daisy@dafox.com", provider: "google", token: "test token 2"}

  describe "edit/2" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      {:ok, album: album, user: user}
    end

    test "redirects for user authentication", %{conn: conn, album: album} do
      conn = get(conn, Routes.tag_path(conn, :edit, album.apple_album_id))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "serves edit page to authenticated users", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.tag_path(conn, :edit, album.apple_album_id))
      assert html_response(conn, 200) =~ ~s(<div id="tag-input-container" class="chips">)
    end
  end

  describe "create/2" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      {:ok, album: album, user: user}
    end

    test "redirects for user authentication", %{conn: conn, album: album} do
      conn = post(conn, Routes.tag_path(conn, :create, %{"album" => album.apple_album_id, "tag" => "Super New Tag", "customGenre" => false}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "creates a tag when all params are passed", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.tag_path(conn, :create, %{"album" => album.apple_album_id, "tag" => "Super New Tag", "customGenre" => false}))
      new_tag = Repo.get_by(Tag, %{text: "Super New Tag", user_id: user.id, custom_genre: false})

      assert response = json_response(conn, 200)
      assert response["message"] == "Tag successfully created"
      assert response["tag_id"] == new_tag.id
    end

    test "does not create tags when tag is too short", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.tag_path(conn, :create, %{"album" => album.apple_album_id, "tag" => "S", "customGenre" => false}))
      created_tag = Repo.get_by(Tag, %{text: "S", user_id: user.id, custom_genre: false})

      assert response = json_response(conn, 400)
      assert response["message"] == "Tags must be at least two characters long"
      assert response["tag_id"] == nil
      assert created_tag == nil
    end

    test "does not create tags when tag is too long", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.tag_path(conn, :create, %{"album" => album.apple_album_id, "tag" => "This is by far the longest tag I could think of", "customGenre" => false}))
      created_tag = Repo.get_by(Tag, %{text: "This is by far the longest tag I could think of", user_id: user.id, custom_genre: false})

      assert response = json_response(conn, 400)
      assert response["message"] == "Tags cannot be more than thirty characters long"
      assert response["tag_id"] == nil
      assert created_tag == nil
    end

    test "does not create tags when tag contains disallowed characters", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.tag_path(conn, :create, %{"album" => album.apple_album_id, "tag" => "function() {sneaky tag}", "customGenre" => false}))
      created_tag = Repo.get_by(Tag, %{text: "function() {sneaky tag}", user_id: user.id, custom_genre: false})

      assert response = json_response(conn, 400)
      assert response["message"] == "Some characters are not allowed in tags"
      assert response["tag_id"] == nil
      assert created_tag == nil
    end
  end

  describe "delete/2" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      tag = tag_fixture(%{text: "New Tag", user_id: user.id, album_id: album.id})
      {:ok, album: album, user: user, tag: tag}
    end

    test "redirects for user authentication", %{conn: conn, album: album, tag: tag} do
      conn = delete(conn, Routes.tag_path(conn, :delete, tag.id, %{"albumID" => album.id}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "unassociates a tag from an album", %{conn: conn, user: user, album: album, tag: tag} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      album_before = Repo.get(Album, album.id) |> Repo.preload([:tags])
      conn = delete(conn, Routes.tag_path(conn, :delete, tag.id, %{"albumID" => album.id}))
      album_after = Repo.get(Album, album.id) |> Repo.preload([:tags])

      assert List.first(album_before.tags).id == tag.id
      assert album_after.tags == []

      assert response = json_response(conn, 200)
      assert response["message"] == "Tag deleted"
      assert response["tag_id"] == nil
    end

    test "does not actually delete the tag record itself", %{conn: conn, user: user, album: album, tag: tag} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = delete(conn, Routes.tag_path(conn, :delete, tag.id, %{"albumID" => album.id}))
      deleted_tag = Repo.get_by(Tag, %{text: "New Tag", user_id: user.id, custom_genre: false})

      assert response = json_response(conn, 200)
      assert deleted_tag.id == tag.id
    end

    test "won't remove an album_tag created by another user", %{conn: conn, album: album, tag: tag} do
      conn = Plug.Test.init_test_session(conn, user_id: user_fixture(@alt_user_attrs).id)
      album_before = Repo.get(Album, album.id) |> Repo.preload([:tags])
      conn = delete(conn, Routes.tag_path(conn, :delete, tag.id, %{"albumID" => album.id}))
      album_after = Repo.get(Album, album.id) |> Repo.preload([:tags])

      assert album_before.tags == album_after.tags
      assert response = json_response(conn, 500)
      assert response["message"] == "Unable to delete tag"
      assert response["tag_id"] == nil
    end
  end
end
