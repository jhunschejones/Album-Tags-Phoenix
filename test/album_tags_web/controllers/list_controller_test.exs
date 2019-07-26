defmodule AlbumTagsWeb.ListControllerTest do
  use AlbumTagsWeb.ConnCase

  alias AlbumTags.{Lists, Repo}

  @album_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @album_two_attrs %{apple_album_id: 1135092935, apple_url: "https://itunes.apple.com/us/album/passengers/1135092935", title: "Passengers", artist: "Artifex Pereo", release_date: "2016-09-09", record_company: "Tooth & Nail Records", cover: "https://is2-ssl.mzstatic.com/image/thumb/Music20/v4/c5/64/ce/c564ce15-0e87-458c-cbb0-9941d65b5648/886446002583.jpg/{w}x{h}bb.jpeg"}
  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}
  @list_attrs %{title: "Super Test List", private: false}
  @alt_user_attrs %{name: "Daisy Bear", email: "daisy@dafox.com", provider: "google", token: "test token 2"}

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

  describe "new/2" do
    setup do
      album = album_fixture(@album_attrs)
      {:ok, album: album}
    end

    test "redirects for user authentication", %{conn: conn, album: album} do
      conn = get(conn, Routes.list_path(conn, :new, %{"album" => album.apple_album_id}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "serves new page to authenticated users", %{conn: conn, album: album} do
      user = user_fixture(@user_attrs)
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = get(conn, Routes.list_path(conn, :new, %{"album" => album.apple_album_id}))
      assert html_response(conn, 200) =~ ~s(<div id="existing-list-container")
    end
  end

  describe "create/2 with no current album" do
    setup do
      user = user_fixture(@user_attrs)
      {:ok, user: user}
    end

    test "redirects for user authentication", %{conn: conn} do
      conn = post(conn, Routes.list_path(conn, :create, %{"title" => @list_attrs.title, "private" => @list_attrs.private}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "creates a new list", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.list_path(conn, :create, %{"title" => @list_attrs.title, "private" => @list_attrs.private}))
      list = Lists.get_list_by(%{title: @list_attrs.title, user_id: user.id})

      assert response = json_response(conn, 200)
      assert response["message"] == "List successfully created"
      assert response["new_list"]["title"] == @list_attrs.title
      assert list.title == @list_attrs.title
    end

    test "doesn't allow duplicate lists", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      list_fixture(%{title: @list_attrs.title, user_id: user.id})
      conn = post(conn, Routes.list_path(conn, :create, %{"title" => @list_attrs.title, "private" => @list_attrs.private}))

      assert json_response(conn, 400) =~ "You already created a list with that tile"
    end

    test "creates 'My Favorites' list", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.list_path(conn, :create, %{"title" => "my  favorites ", "private" => @list_attrs.private}))
      list = Lists.get_list_by(%{title: "My Favorites", user_id: user.id})

      assert response = json_response(conn, 200)
      assert response["message"] == "List successfully created"
      assert response["new_list"]["title"] == "My Favorites"
      assert list.title == "My Favorites"
    end

    test "stores new 'My Favorites' list_id in session", %{conn: conn, user: user} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.list_path(conn, :create, %{"title" => "My Favorites", "private" => @list_attrs.private}))
      list = Lists.get_list_by(%{title: "My Favorites", user_id: user.id})

      assert get_session(conn, :favorites_list_id) == list.id
    end
  end

  describe "create/2 with current album" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      {:ok, user: user, album: album}
    end

    test "redirects for user authentication", %{conn: conn, album: album} do
      conn = post(conn, Routes.list_path(conn, :create, %{"title" => @list_attrs.title, "private" => @list_attrs.private, "currentAlbum" => album.apple_album_id}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "creates a new list", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.list_path(conn, :create, %{"title" => @list_attrs.title, "private" => @list_attrs.private, "currentAlbum" => album.apple_album_id}))
      list = Lists.get_list_by(%{title: @list_attrs.title, user_id: user.id}) |> Repo.preload([:albums])

      assert response = json_response(conn, 200)
      assert response == "List successfully created"
      assert list.title == @list_attrs.title
    end

    test "doesn't allow duplicate lists", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      list_fixture(%{title: @list_attrs.title, user_id: user.id})
      conn = post(conn, Routes.list_path(conn, :create, %{"title" => @list_attrs.title, "private" => @list_attrs.private, "currentAlbum" => album.apple_album_id}))

      assert json_response(conn, 400) =~ "You already created a list with that tile"
    end

    test "doesn't allow lists to be created with 'My Favorites' title", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = post(conn, Routes.list_path(conn, :create, %{"title" => "My Favorites", "private" => @list_attrs.private, "currentAlbum" => album.apple_album_id}))

      assert json_response(conn, 400) =~ "The 'My Favorites' list already exists"
    end
  end

  describe "update/2 when action == 'add_album'" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      list = list_fixture(%{title: @list_attrs.title, user_id: user.id})
      {:ok, user: user, album: album, list: list}
    end

    test "redirects for user authentication", %{conn: conn, album: album, list: list} do
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "add_album", "currentAlbum" => album.apple_album_id}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "adds an album to a list", %{conn: conn, user: user, album: album, list: list} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "add_album", "currentAlbum" => album.apple_album_id}))
      updated_list = Lists.get_list_by(%{id: list.id}) |> Repo.preload([:albums])

      assert response = json_response(conn, 200)
      assert response["message"] == "Album successfully added to list"
      assert response["added_album"]["apple_album_id"] == album.apple_album_id
      assert List.first(updated_list.albums).apple_album_id == album.apple_album_id
    end

    test "prevents adding a duplicate album to a list", %{conn: conn, user: user, album: album} do
      list = list_fixture(%{title: "Another Test List", user_id: user.id, album_id: album.id})
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "add_album", "currentAlbum" => album.apple_album_id}))

      assert response = json_response(conn, 400)
      assert response == "You already added the album to this list"
    end

    # hi-lighting that this is possible through the controller, just not yet used in the UI
    test "a user can add an album to another user's list", %{conn: conn, user: user, album: album, list: list} do
      alt_user = user_fixture(@alt_user_attrs)
      conn = Plug.Test.init_test_session(conn, user_id: alt_user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "add_album", "currentAlbum" => album.apple_album_id}))
      updated_list = Lists.get_list_by(%{id: list.id}) |> Repo.preload([:albums])

      assert response = json_response(conn, 200)
      assert response["message"] == "Album successfully added to list"
      assert response["added_album"]["apple_album_id"] == album.apple_album_id
      assert List.first(updated_list.albums).apple_album_id == album.apple_album_id
      assert updated_list.user_id == user.id
    end
  end

  # the `id` param is not used at this endpoint
  describe "update/2 when action == 'add_favorite'" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      list = list_fixture(%{title: "My Favorites", user_id: user.id})
      {:ok, user: user, album: album, list: list}
    end

    test "redirects for user authentication", %{conn: conn, album: album} do
      conn = patch(conn, Routes.list_path(conn, :update, 1, %{"action" => "add_favorite", "currentAlbum" => album.apple_album_id}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "adds an album to a users 'My Favorites' list", %{conn: conn, user: user, album: album} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, 1, %{"action" => "add_favorite", "currentAlbum" => album.apple_album_id}))
      updated_list = Lists.get_list_by(%{user_id: user.id, title: "My Favorites"}) |> Repo.preload([:albums])

      assert response = json_response(conn, 200)
      assert response == "Album successfully added to your favorites"
      assert List.first(updated_list.albums).apple_album_id == album.apple_album_id
    end

    test "prevents adding a duplicate album to a list", %{conn: conn, user: user, album: album, list: list} do
      Lists.add_album_to_list(%{list_id: list.id, user_id: user.id, album_id: album.id})
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, 1, %{"action" => "add_favorite", "currentAlbum" => album.apple_album_id}))

      assert response = json_response(conn, 400)
      assert response == "You already added the album to this list"
    end
  end

  describe "update/2 when action == 'remove_album'" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_attrs)
      list = list_fixture(%{title: @list_attrs.title, user_id: user.id, album_id: album.id})
      {:ok, user: user, album: album, list: list}
    end

    test "redirects for user authentication", %{conn: conn, album: album, list: list} do
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "remove_album", "albumID" => album.id}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "removes an album from a list", %{conn: conn, user: user, album: album, list: list} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "remove_album", "albumID" => album.id}))
      updated_list = Lists.get_list_by(%{id: list.id}) |> Repo.preload([:albums])

      assert response = json_response(conn, 200)
      assert response == "Album successfully removed from list"
      assert updated_list.albums == []
    end

    test "doesn't blow up when an album that isn't in a list", %{conn: conn, user: user, list: list} do
      alt_album = album_fixture(@album_two_attrs)
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "remove_album", "albumID" => alt_album.id}))

      assert response = json_response(conn, 400)
      assert response == "Unable to remove album from list"
    end

    test "doesn't remove an album from another user's list", %{conn: conn, album: album, list: list} do
      alt_user = user_fixture(@alt_user_attrs)
      conn = Plug.Test.init_test_session(conn, user_id: alt_user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "remove_album", "albumID" => album.id}))
      updated_list = Lists.get_list_by(%{id: list.id}) |> Repo.preload([:albums])

      assert response = json_response(conn, 400)
      assert response == "You can't remove an album from someone else's list"
      assert List.first(updated_list.albums).apple_album_id == @album_attrs.apple_album_id
    end
  end

  describe "update/2 when action == 'update_title'" do
    setup do
      user = user_fixture(@user_attrs)
      list = list_fixture(%{title: @list_attrs.title, user_id: user.id})
      {:ok, user: user, list: list}
    end

    test "redirects for user authentication", %{conn: conn, list: list} do
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "update_title", "newTitle" => "New Test List Title"}))
      assert "/auth/google" = redirected_to(conn, 302)
    end

    test "updates title with valid input", %{conn: conn, user: user, list: list} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "update_title", "newTitle" => "New test list  title "}))
      updated_list = Lists.get_list_by(%{id: list.id})

      assert response = json_response(conn, 200)
      assert response["message"] == "List title successfully updated"
      assert response["list_title"] == "New Test List Title"
      assert updated_list.title == "New Test List Title"
    end

    test "won't allow blank list titles", %{conn: conn, user: user, list: list} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "update_title", "newTitle" => ""}))
      updated_list = Lists.get_list_by(%{id: list.id})

      assert response = json_response(conn, 400)
      assert response == "List titles must be at least two characters long"
      assert updated_list.title == @list_attrs.title
    end

    test "won't allow short list titles", %{conn: conn, user: user, list: list} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "update_title", "newTitle" => "b"}))
      updated_list = Lists.get_list_by(%{id: list.id})

      assert response = json_response(conn, 400)
      assert response == "List titles must be at least two characters long"
      assert updated_list.title == @list_attrs.title
    end

    test "won't allow long list titles", %{conn: conn, user: user, list: list} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "update_title", "newTitle" => "This title is so incredibly long, it's not entirely practical anymore in terms of display"}))
      updated_list = Lists.get_list_by(%{id: list.id})

      assert response = json_response(conn, 400)
      assert response == "List titles cannot be more than sixty characters long"
      assert updated_list.title == @list_attrs.title
    end

    test "won't let user update another user's list", %{conn: conn, list: list} do
      alt_user = user_fixture(@alt_user_attrs)
      conn = Plug.Test.init_test_session(conn, user_id: alt_user.id)
      conn = patch(conn, Routes.list_path(conn, :update, list.id, %{"action" => "update_title", "newTitle" => "New test list  title "}))
      updated_list = Lists.get_list_by(%{id: list.id})

      assert response = json_response(conn, 400)
      assert response == "You can't change the title of someone else's list"
      assert updated_list.title == @list_attrs.title
    end
  end

  describe "delete/2" do
    setup do
      user = user_fixture(@user_attrs)
      list = list_fixture(%{title: @list_attrs.title, user_id: user.id})
      {:ok, user: user, list: list}
    end

    test "deletes list", %{conn: conn, user: user, list: list} do
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = delete(conn, Routes.list_path(conn, :delete, list.id))
      deleted_list = Lists.get_list_by(%{id: list.id})

      assert response = json_response(conn, 200)
      assert response == "List successfully deleted"
      assert deleted_list == nil
    end

    test "deletes 'My Favorites' and removes from session", %{conn: conn, user: user} do
      list = list_fixture(%{title: "My Favorites", user_id: user.id})
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      conn = delete(conn, Routes.list_path(conn, :delete, list.id))
      deleted_list = Lists.get_list_by(%{id: list.id})

      assert response = json_response(conn, 200)
      assert response == "List successfully deleted"
      assert deleted_list == nil
      assert get_session(conn, :favorites_list_id) == nil
    end

    test "doesn't delete another user's list", %{conn: conn, list: list} do
      alt_user = user_fixture(@alt_user_attrs)
      conn = Plug.Test.init_test_session(conn, user_id: alt_user.id)
      conn = delete(conn, Routes.list_path(conn, :delete, list.id))
      deleted_list = Lists.get_list_by(%{id: list.id})

      assert response = json_response(conn, 400)
      assert response == "You can't delete someone else's list"
      assert deleted_list.title == @list_attrs.title
    end
  end
end
