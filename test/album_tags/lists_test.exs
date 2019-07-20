defmodule AlbumTags.ListsTest do
  use AlbumTags.DataCase

  alias AlbumTags.Lists

  @user_one_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}
  @album_one_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @album_two_attrs %{apple_album_id: 1135092935, apple_url: "https://itunes.apple.com/us/album/passengers/1135092935", title: "Passengers", artist: "Artifex Pereo", release_date: "2016-09-09", record_company: "Tooth & Nail Records", cover: "https://is2-ssl.mzstatic.com/image/thumb/Music20/v4/c5/64/ce/c564ce15-0e87-458c-cbb0-9941d65b5648/886446002583.jpg/{w}x{h}bb.jpeg"}

  describe "create_list/1" do
    test "prevents titles from being too long" do
      {:error, %{errors: reason}} = Lists.create_list(%{
        title: "This is the longest list title you've ever seen. Far longer than you should really be using.",
        user_id: user_fixture(@user_one_attrs).id
      })

      assert reason == [title: {"should be at most %{count} character(s)", [count: 60, validation: :length, kind: :max, type: :string]}]
    end

    test "prevents titles from being too short" do
      {:error, %{errors: reason}} = Lists.create_list(%{title: "B", user_id: user_fixture(@user_one_attrs).id})
      assert reason == [title: {"should be at least %{count} character(s)", [count: 2, validation: :length, kind: :min, type: :string]}]
    end
  end

  describe "get_list_with_all_assoc/1" do
    setup do
      user = user_fixture(@user_one_attrs)
      album = album_fixture(@album_one_attrs)
      tag_fixture(%{text: "New Tag", user_id: user.id, album_id: album.id})
      list = list_fixture(%{title: "A Very Test List", user_id: user.id, album_id: album.id})
      {:ok, list: list}
    end

    test "returns list with required preloaded associations", %{list: list} do
      found_list = Lists.get_list_with_all_assoc(list.id)
      assert Ecto.assoc_loaded?(found_list.albums) == true
      assert Ecto.assoc_loaded?(List.first(found_list.albums).tags) == true
      assert Ecto.assoc_loaded?(List.first(List.first(found_list.albums).tags).user) == true
    end
  end

  describe "get_user_lists/1" do
    setup do
      user = user_fixture(@user_one_attrs)
      list_fixture(%{title: "A Very Test List", user_id: user.id, album_id: album_fixture(@album_one_attrs).id})
      list_fixture(%{title: "Another Test List", user_id: user.id, album_id: album_fixture(@album_two_attrs).id})
      {:ok, user: user}
    end

    test "returns all lists for a user", %{user: user} do
      user_lists = Lists.get_user_lists(user.id)
      assert length(user_lists) == 2
      assert List.first(user_lists).title == "Another Test List"
    end
  end

  describe "find_or_create_favorites/1" do
    setup do
      user = user_fixture(@user_one_attrs)
      {:ok, user: user}
    end

    test "returns new favorites list", %{user: user} do
      favorites = Lists.find_or_create_favorites(user.id)
      assert favorites.title == "My Favorites"
    end

    test "returns existing favorites list", %{user: user} do
      existing_favorites = list_fixture(%{title: "My Favorites", user_id: user.id})
      found_favorites = Lists.find_or_create_favorites(user.id)
      assert found_favorites.id == existing_favorites.id
    end
  end

  describe "update_title/1" do
    setup do
      user = user_fixture(@user_one_attrs)
      list = list_fixture(%{title: "A Very Test List", user_id: user.id})
      {:ok, user: user, list: list}
    end

    test "changes a lists title", %{user: user, list: list} do
      Lists.update_title(%{list_id: list.id, title: "Super updated title", user_id: user.id})
      updated_list = Repo.get(Lists.List, list.id)

      assert list.id == updated_list.id
      assert updated_list.title != list.title
      assert updated_list.title == "Super Updated Title"
    end
  end

  describe "remove_album_from_list/1" do
    setup do
      user = user_fixture(@user_one_attrs)
      album = album_fixture(@album_one_attrs)
      list = list_fixture(%{title: "A Very Test List", user_id: user.id, album_id: album.id})
      {:ok, user: user, album: album, list: list}
    end

    test "removes album from list", %{user: user, album: album, list: list} do
      assert length(Lists.get_list_with_all_assoc(list.id).albums) == 1
      Lists.remove_album_from_list(%{album_id: album.id, list_id: list.id, user_id: user.id})
      assert length(Lists.get_list_with_all_assoc(list.id).albums) == 0
    end
  end
end
