defmodule AlbumTags.ListsTest do
  use AlbumTags.DataCase

  alias AlbumTags.Lists

  describe "lists" do
    @user_one_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}
    @album_one_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
    @album_two_attrs %{apple_album_id: 1135092935, apple_url: "https://itunes.apple.com/us/album/passengers/1135092935", title: "Passengers", artist: "Artifex Pereo", release_date: "2016-09-09", record_company: "Tooth & Nail Records", cover: "https://is2-ssl.mzstatic.com/image/thumb/Music20/v4/c5/64/ce/c564ce15-0e87-458c-cbb0-9941d65b5648/886446002583.jpg/{w}x{h}bb.jpeg"}

    setup do
      user_one = user_fixture(@user_one_attrs)
      album_one = album_fixture(@album_one_attrs)
      album_two = album_fixture(@album_two_attrs)
      tag_fixture(%{text: "New Tag", user_id: user_one.id, album_id: album_one.id})
      tag_fixture(%{text: "Another New Tag", user_id: user_one.id, album_id: album_two.id})
      list_one = list_fixture(%{title: "A Very Test List", user_id: user_one.id, album_id: album_one.id})
      list_fixture(%{title: "Another Test List", user_id: user_one.id, album_id: album_two.id})
      {:ok, user_one: user_one, album_one: album_one, list_one: list_one}
    end

    test "create_list/1 throws changeset error with title too long", %{user_one: user} do
      {:error, %{errors: reason}} = Lists.create_list(%{
        title: "This is the longest list title you've ever seen. Far longer than you should really be using.",
        user_id: user.id
      })

      assert reason == [title: {"should be at most %{count} character(s)", [count: 60, validation: :length, kind: :max, type: :string]}]
    end

    test "create_list/1 throws changeset error with title too short", %{user_one: user} do
      {:error, %{errors: reason}} = Lists.create_list(%{
        title: "B",
        user_id: user.id
      })

      assert reason == [title: {"should be at least %{count} character(s)", [count: 2, validation: :length, kind: :min, type: :string]}]
    end

    test "get_list_with_all_assoc/1 returns list with required preloaded associations", %{list_one: list} do
      found_list = Lists.get_list_with_all_assoc(list.id)
      assert Ecto.assoc_loaded?(found_list.albums) == true
      assert Ecto.assoc_loaded?(List.first(found_list.albums).tags) == true
      assert Ecto.assoc_loaded?(List.first(List.first(found_list.albums).tags).user) == true
    end

    test "get_user_lists/1 returns all lists for a user", %{user_one: user} do
      user_lists = Lists.get_user_lists(user.id)
      assert length(user_lists) == 2
      assert List.first(user_lists).title == "Another Test List"
    end

    test "find_or_create_favorites/1 returns new favorites list", %{user_one: user} do
      favorites = Lists.find_or_create_favorites(user.id)
      assert favorites.title == "My Favorites"
    end

    test "find_or_create_favorites/1 returns existing favorites list", %{user_one: user} do
      existing_favorites = list_fixture(%{title: "My Favorites", user_id: user.id})
      found_favorites = Lists.find_or_create_favorites(user.id)
      assert found_favorites.id == existing_favorites.id
    end

    test "update_title/1 changes a lists title", %{list_one: list, user_one: user} do
      Lists.update_title(%{list_id: list.id, title: "Super updated title", user_id: user.id})
      updated_list = Repo.get(Lists.List, list.id)

      assert list.id == updated_list.id
      assert updated_list.title != list.title
      assert updated_list.title == "Super updated title"
    end

    test "remove_album_from_list/1 removes album from list", %{list_one: list, album_one: album, user_one: user} do
      assert length(Lists.get_list_with_all_assoc(list.id).albums) == 1
      Lists.remove_album_from_list(%{album_id: album.id, list_id: list.id, user_id: user.id})
      assert length(Lists.get_list_with_all_assoc(list.id).albums) == 0
    end
  end
end
