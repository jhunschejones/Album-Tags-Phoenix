defmodule AlbumTags.AlbumsTest do
  use AlbumTags.DataCase, async: true

  alias AlbumTags.Albums
  alias AlbumTags.Accounts
  alias AlbumTags.Albums.Album

  @album_one_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @album_two_attrs %{apple_album_id: 1135092935, apple_url: "https://itunes.apple.com/us/album/passengers/1135092935", title: "Passengers", artist: "Artifex Pereo", release_date: "2016-09-09", record_company: "Tooth & Nail Records", cover: "https://is2-ssl.mzstatic.com/image/thumb/Music20/v4/c5/64/ce/c564ce15-0e87-458c-cbb0-9941d65b5648/886446002583.jpg/{w}x{h}bb.jpeg"}
  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}

  describe "albums" do
    setup do
      {:ok, album_one: album_fixture(@album_one_attrs)}
      {:ok, album_two: album_fixture(@album_two_attrs)}
      {:ok, user: user_fixture(@user_attrs)}
      {:ok, connection: connection_fixture(
        Repo.get_by(Album, apple_album_id: @album_one_attrs.apple_album_id),
        Repo.get_by(Album, apple_album_id: @album_two_attrs.apple_album_id),
        Repo.get_by(Accounts.User, email: @user_attrs.email)
      )}
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
  end

  describe "tags" do
    alias AlbumTags.Albums.Tag

    @valid_attrs %{custom_genre: true, text: "some text", user_id: 42}
    @update_attrs %{custom_genre: false, text: "some updated text", user_id: 43}
    @invalid_attrs %{custom_genre: nil, text: nil, user_id: nil}

    def tag_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Albums.create_tag()

      tag
    end

    # test "list_tags/0 returns all tags" do
    #   tag = tag_fixture()
    #   assert Albums.list_tags() == [tag]
    # end
  end

  describe "songs" do
    alias AlbumTags.Albums.Song

    @valid_attrs %{album_id: 42, length: "some length", order: 42, title: "some title"}
    @update_attrs %{album_id: 43, length: "some updated length", order: 43, title: "some updated title"}
    @invalid_attrs %{album_id: nil, length: nil, order: nil, title: nil}

    def song_fixture(attrs \\ %{}) do
      {:ok, song} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Albums.create_song()

      song
    end

    # test "list_songs/0 returns all songs" do
    #   song = song_fixture()
    #   assert Albums.list_songs() == [song]
    # end
  end
end
