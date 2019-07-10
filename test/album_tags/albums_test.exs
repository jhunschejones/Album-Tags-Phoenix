defmodule AlbumTags.AlbumsTest do
  use AlbumTags.DataCase, async: true

  alias AlbumTags.Albums

  @album_one_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @album_two_attrs %{apple_album_id: 1135092935, apple_url: "https://itunes.apple.com/us/album/passengers/1135092935", title: "Passengers", artist: "Artifex Pereo", release_date: "2016-09-09", record_company: "Tooth & Nail Records", cover: "https://is2-ssl.mzstatic.com/image/thumb/Music20/v4/c5/64/ce/c564ce15-0e87-458c-cbb0-9941d65b5648/886446002583.jpg/{w}x{h}bb.jpeg"}
  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}

  describe "albums" do
    setup do
      album_one = album_fixture(@album_one_attrs)
      album_two = album_fixture(@album_two_attrs)
      user = user_fixture(@user_attrs)
      connection_fixture(album_one, album_two, user)

      {:ok, album_one: album_one, album_two: album_two, user: user}
    end

    test "get_album_with/2 returns apple api data for album not in the database" do
      album = Albums.get_album_with(1113863913)
      assert album.title == "Periphery III: Select Difficulty"
      assert album.artist == "Periphery"
    end

    test "get_album_with/2 returns album with all resources when resource is not specified" do
      album = Albums.get_album_with(716394623)
      assert Ecto.assoc_loaded?(album.tags) == true
      assert List.first(album.connections).apple_album_id == @album_two_attrs.apple_album_id
      assert Ecto.assoc_loaded?(album.lists) == true
    end

    test "get_album_with/2 returns album with tags when resource is specified" do
      album = Albums.get_album_with(716394623, [:tags])
      assert Ecto.assoc_loaded?(album.tags) == true
      assert album.connections == nil
      assert Ecto.assoc_loaded?(album.lists) == false
    end

    test "get_album_with/2 returns album with connections when resource is specified" do
      album = Albums.get_album_with(716394623, [:connections])
      assert Ecto.assoc_loaded?(album.tags) == false
      assert List.first(album.connections).apple_album_id == @album_two_attrs.apple_album_id
      assert Ecto.assoc_loaded?(album.lists) == false
    end

    test "get_album_with/2 returns album with lists when resource is specified" do
      album = Albums.get_album_with(716394623, [:lists])
      assert Ecto.assoc_loaded?(album.tags) == false
      assert album.connections == nil
      assert Ecto.assoc_loaded?(album.lists) == true
    end

    test "get_album_with/2 returns album with lists and their associated albums when resources are specified", %{album_one: album_one, user: user} do
      list_fixture(%{title: "Test List", user_id: user.id, album_id: album_one.id})
      album = Albums.get_album_with(716394623, [lists: [:albums]])

      assert Ecto.assoc_loaded?(album.tags) == false
      assert album.connections == nil
      assert Ecto.assoc_loaded?(album.lists) == true
      assert Ecto.assoc_loaded?(List.first(album.lists).albums) == true
    end
  end

  describe "tags" do
    alias AlbumTags.Albums.Tag

    setup do
      {:ok, user: user_fixture(@user_attrs), album: album_fixture(@album_one_attrs)}
    end

    test "find_or_create_tag/1 creates a new tag", %{user: user} do
      existing_tag = Repo.get_by(Tag, text: "New Tag", user_id: user.id, custom_genre: false)
      {:ok, found_tag} = Albums.find_or_create_tag(%{text: "New Tag", user_id: user.id, custom_genre: false})

      assert existing_tag == nil
      assert found_tag.id != nil
      assert found_tag.text == "New Tag"
    end

    test "find_or_create_tag/1 returns existing tag", %{user: user, album: album} do
      existing_tag = tag_fixture(%{text: "New Tag", user_id: user.id, album_id: album.id})
      {:ok, found_tag} = Albums.find_or_create_tag(%{text: "New Tag", user_id: user.id, custom_genre: false})

      assert found_tag.id == existing_tag.id
      assert found_tag.text == existing_tag.text
    end

    test "find_or_create_tag/1 throws changeset error when tag is too short" do
      {:error, %{errors: errors}} = Albums.find_or_create_tag(%{custom_genre: false, text: "T", user_id: 1})
      assert List.first(errors) == {:text, {"should be at least %{count} character(s)", [count: 2, validation: :length, kind: :min, type: :string]}}
    end

    test "find_or_create_tag/1 throws changeset error when tag is too long" do
      {:error, %{errors: errors}} = Albums.find_or_create_tag(%{custom_genre: false, text: "This is the longest tag you have ever thought of", user_id: 1})
      assert List.first(errors) == {:text, {"should be at most %{count} character(s)", [count: 30, validation: :length, kind: :max, type: :string]}}
    end

    test "search_by_tags/1 returns all matching tags", %{user: user, album: album} do
      tag_fixture(%{text: "Emo", user_id: user.id, album_id: album.id})
      tag_fixture(%{text: "Rock", user_id: user.id, album_id: album.id})
      tag_fixture(%{text: "Metal", user_id: user.id, album_id: album.id})

      album_two = album_fixture(@album_two_attrs)
      tag_fixture(%{text: "Emo", user_id: user.id, album_id: album_two.id})

      results = Albums.search_by_tags("Emo,,Rock")

      assert length(results) == 1
      assert List.first(results).apple_album_id == @album_one_attrs.apple_album_id
    end
  end
end
