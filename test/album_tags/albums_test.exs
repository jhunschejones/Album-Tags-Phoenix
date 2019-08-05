defmodule AlbumTags.AlbumsTest do
  use AlbumTags.DataCase

  alias AlbumTags.Albums
  alias AlbumTags.Albums.Tag

  @album_one_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @album_two_attrs %{apple_album_id: 1135092935, apple_url: "https://itunes.apple.com/us/album/passengers/1135092935", title: "Passengers", artist: "Artifex Pereo", release_date: "2016-09-09", record_company: "Tooth & Nail Records", cover: "https://is2-ssl.mzstatic.com/image/thumb/Music20/v4/c5/64/ce/c564ce15-0e87-458c-cbb0-9941d65b5648/886446002583.jpg/{w}x{h}bb.jpeg"}
  @invalid_album_attrs %{apple_album_id: 1, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}

  describe "get_album_with/2" do
    test "returns apple api data for album not in the database" do
      album = Albums.get_album_with(715622601)
      assert album.title == "I'm Only a Man (Bonus Track Version)"
      assert album.artist == "Emery"
    end

    test "gracefully handles invalid apple album id" do
      assert Albums.get_album_with("boop") == {:error, nil}
      assert Albums.get_album_with(1) == {:error, nil}
    end

    test "returns album with all resources when resource is not specified" do
      connection_fixture(album_fixture(@album_one_attrs), album_fixture(@album_two_attrs), user_fixture(@user_attrs))
      found_album = Albums.get_album_with(@album_one_attrs.apple_album_id)

      assert Ecto.assoc_loaded?(found_album.tags) == true
      assert List.first(found_album.connections).apple_album_id == @album_two_attrs.apple_album_id
      assert Ecto.assoc_loaded?(found_album.lists) == true
    end

    test "returns album with tags when resource is specified" do
      connection_fixture(album_fixture(@album_one_attrs), album_fixture(@album_two_attrs), user_fixture(@user_attrs))
      found_album = Albums.get_album_with(@album_one_attrs.apple_album_id, [:tags])

      assert Ecto.assoc_loaded?(found_album.tags) == true
      assert found_album.connections == nil
      assert Ecto.assoc_loaded?(found_album.lists) == false
    end

    test "returns album with connections when resource is specified" do
      connection_fixture(album_fixture(@album_one_attrs), album_fixture(@album_two_attrs), user_fixture(@user_attrs))
      found_album = Albums.get_album_with(@album_one_attrs.apple_album_id, [:connections])

      assert Ecto.assoc_loaded?(found_album.tags) == false
      assert List.first(found_album.connections).apple_album_id == @album_two_attrs.apple_album_id
      assert Ecto.assoc_loaded?(found_album.lists) == false
    end

    test "returns album with lists when resource is specified" do
      connection_fixture(album_fixture(@album_one_attrs), album_fixture(@album_two_attrs), user_fixture(@user_attrs))
      found_album = Albums.get_album_with(@album_one_attrs.apple_album_id, [:lists])

      assert Ecto.assoc_loaded?(found_album.tags) == false
      assert found_album.connections == nil
      assert Ecto.assoc_loaded?(found_album.lists) == true
    end

    test "returns album with lists and their associated albums when resources are specified" do
      album = album_fixture(@album_one_attrs)
      user = user_fixture(@user_attrs)
      connection_fixture(album, album_fixture(@album_two_attrs), user)
      list_fixture(%{title: "Test List", user_id: user.id, album_id: album.id})
      found_album = Albums.get_album_with(@album_one_attrs.apple_album_id, [lists: [:albums]])

      assert Ecto.assoc_loaded?(found_album.tags) == false
      assert found_album.connections == nil
      assert Ecto.assoc_loaded?(found_album.lists) == true
      assert Ecto.assoc_loaded?(List.first(found_album.lists).albums) == true
    end
  end

  describe "find_or_create_tag/1" do
    test "creates a new tag" do
      user = user_fixture(@user_attrs)
      existing_tag = Repo.get_by(Tag, text: "New Tag", user_id: user.id, custom_genre: false)
      {:ok, found_tag} = Albums.find_or_create_tag(%{text: "New Tag", user_id: user.id, custom_genre: false})

      assert existing_tag == nil
      assert found_tag.id != nil
      assert found_tag.text == "New Tag"
    end

    test "returns existing tag" do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_one_attrs)
      existing_tag = tag_fixture(%{text: "New Tag", user_id: user.id, album_id: album.id})
      {:ok, found_tag} = Albums.find_or_create_tag(%{text: "New Tag", user_id: user.id, custom_genre: false})

      assert found_tag.id == existing_tag.id
      assert found_tag.text == existing_tag.text
    end

    test "prevents tag text from being too short" do
      {:error, %{errors: errors}} = Albums.find_or_create_tag(%{custom_genre: false, text: "T", user_id: 1})
      assert List.first(errors) == {:text, {"should be at least %{count} character(s)", [count: 2, validation: :length, kind: :min, type: :string]}}
    end

    test "prevents tag text from being too long" do
      {:error, %{errors: errors}} = Albums.find_or_create_tag(%{custom_genre: false, text: "This is the longest tag you have ever thought of", user_id: 1})
      assert List.first(errors) == {:text, {"should be at most %{count} character(s)", [count: 30, validation: :length, kind: :max, type: :string]}}
    end
  end

  describe "search_by_tags/1" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_one_attrs)
      tag_fixture(%{text: "Emo", user_id: user.id, album_id: album.id})
      tag_fixture(%{text: "Rock", user_id: user.id, album_id: album.id})
      tag_fixture(%{text: "Metal", user_id: user.id, album_id: album.id})
      album_two = album_fixture(@album_two_attrs)
      tag_fixture(%{text: "Emo", user_id: user.id, album_id: album_two.id})

      :ok
    end

    test "returns all matching tags" do
      results = Albums.search_by_tags("Emo,,Rock")
      assert length(results) == 1
      assert List.first(results).apple_album_id == @album_one_attrs.apple_album_id
    end
  end

  describe "remove_tag_from_album/1" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_one_attrs)
      tag_fixture(%{text: "New Tag One", user_id: user.id, album_id: album.id})
      tag_fixture(%{text: "New Tag Two", user_id: user.id, album_id: album.id})
      {:ok, tag} = Albums.find_or_create_tag(%{text: "New Tag One", user_id: user.id, custom_genre: false})

      {:ok, user: user, album: album, tag: tag}
    end

    test "unassociates a tag from an album", %{user: user, album: album, tag: tag} do
      Albums.remove_tag_from_album(%{tag_id: tag.id, user_id: user.id, album_id: album.id})
      updated_tags = Albums.get_album_with(@album_one_attrs.apple_album_id, [:tags]).tags

      assert length(updated_tags) == 1
      assert List.first(updated_tags).text == "New Tag Two"
    end
  end

  describe "delete_orphan_records/1" do
    setup do
      user = user_fixture(@user_attrs)
      album = album_fixture(@album_one_attrs)
      tag = tag_fixture(%{text: "New Tag", user_id: user.id, album_id: album.id})
      {:ok, user: user, album: album, tag: tag}
    end

    test "deletes orphan records older than cutoff", %{user: user, album: album, tag: tag} do
      Albums.remove_tag_from_album(%{tag_id: tag.id, user_id: user.id, album_id: album.id})
      cutoff = NaiveDateTime.utc_now()
      response = Albums.delete_orphan_records(cutoff)
      db_album = Repo.get_by(Albums.Album, apple_album_id: album.apple_album_id)
      db_tag = Repo.get_by(Albums.Tag, id: tag.id)

      assert response == "Deleted 1 orphan albums and 1 orphan tags"
      assert db_album == nil
      assert db_tag == nil
    end

    test "doesn't delete orphan records newer than cutoff", %{user: user, album: album, tag: tag} do
      Albums.remove_tag_from_album(%{tag_id: tag.id, user_id: user.id, album_id: album.id})
      response = Albums.delete_orphan_records()
      db_album = Repo.get_by(Albums.Album, apple_album_id: album.apple_album_id)
      db_tag = Repo.get_by(Albums.Tag, id: tag.id)

      assert response == "Deleted 0 orphan albums and 0 orphan tags"
      refute db_album.id == nil
      refute db_tag.id == nil
    end

    test "doesn't delete records with associations", %{album: album, tag: tag} do
      response = Albums.delete_orphan_records()
      db_album = Repo.get_by(Albums.Album, apple_album_id: album.apple_album_id)
      db_tag = Repo.get_by(Albums.Tag, id: tag.id)

      assert response == "Deleted 0 orphan albums and 0 orphan tags"
      refute db_album.id == nil
      refute db_tag.id == nil
    end
  end

  describe "find_invalid_apple_album_ids/0" do
    test "retrieves invalid apple album ids" do
      album_fixture(@invalid_album_attrs)
      results = Albums.find_invalid_apple_album_ids()

      assert results == [@invalid_album_attrs.apple_album_id]
    end

    test "does not retrieve valid apple album ids" do
      album_fixture(@album_one_attrs)
      results = Albums.find_invalid_apple_album_ids()

      assert results == []
    end
  end

  describe "retrieve_duplicate_albums/0" do
    test "returns albums with duplicate artist and title" do
      album_fixture(@album_two_attrs)
      duplicate_album_one = album_fixture(@album_one_attrs)
      duplicate_album_two = album_fixture(@invalid_album_attrs)
      results = Albums.retrieve_duplicate_albums()

      assert List.first(results) == duplicate_album_one
      assert List.last(results) == duplicate_album_two
    end
  end
end
