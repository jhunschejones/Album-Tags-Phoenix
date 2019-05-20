defmodule AlbumTags.AlbumsTest do
  use AlbumTags.DataCase

  alias AlbumTags.Albums

  describe "albums" do
    alias AlbumTags.Albums.Album

    @valid_attrs %{apple_album_id: 42, apple_url: "some apple_url", artist: "some artist", cover: "some cover", record_company: "some record_company", release_date: "some release_date", title: "some title"}
    @update_attrs %{apple_album_id: 43, apple_url: "some updated apple_url", artist: "some updated artist", cover: "some updated cover", record_company: "some updated record_company", release_date: "some updated release_date", title: "some updated title"}
    @invalid_attrs %{apple_album_id: nil, apple_url: nil, artist: nil, cover: nil, record_company: nil, release_date: nil, title: nil}

    def album_fixture(attrs \\ %{}) do
      {:ok, album} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Albums.create_album()

      album
    end

    test "list_albums/0 returns all albums" do
      album = album_fixture()
      assert Albums.list_albums() == [album]
    end

    test "get_album!/1 returns the album with given id" do
      album = album_fixture()
      assert Albums.get_album!(album.id) == album
    end

    test "create_album/1 with valid data creates a album" do
      assert {:ok, %Album{} = album} = Albums.create_album(@valid_attrs)
      assert album.apple_album_id == 42
      assert album.apple_url == "some apple_url"
      assert album.artist == "some artist"
      assert album.cover == "some cover"
      assert album.record_company == "some record_company"
      assert album.release_date == "some release_date"
      assert album.title == "some title"
    end

    test "create_album/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Albums.create_album(@invalid_attrs)
    end

    test "update_album/2 with valid data updates the album" do
      album = album_fixture()
      assert {:ok, %Album{} = album} = Albums.update_album(album, @update_attrs)
      assert album.apple_album_id == 43
      assert album.apple_url == "some updated apple_url"
      assert album.artist == "some updated artist"
      assert album.cover == "some updated cover"
      assert album.record_company == "some updated record_company"
      assert album.release_date == "some updated release_date"
      assert album.title == "some updated title"
    end

    test "update_album/2 with invalid data returns error changeset" do
      album = album_fixture()
      assert {:error, %Ecto.Changeset{}} = Albums.update_album(album, @invalid_attrs)
      assert album == Albums.get_album!(album.id)
    end

    test "delete_album/1 deletes the album" do
      album = album_fixture()
      assert {:ok, %Album{}} = Albums.delete_album(album)
      assert_raise Ecto.NoResultsError, fn -> Albums.get_album!(album.id) end
    end

    test "change_album/1 returns a album changeset" do
      album = album_fixture()
      assert %Ecto.Changeset{} = Albums.change_album(album)
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

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Albums.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Albums.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      assert {:ok, %Tag{} = tag} = Albums.create_tag(@valid_attrs)
      assert tag.custom_genre == true
      assert tag.text == "some text"
      assert tag.user_id == 42
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Albums.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{} = tag} = Albums.update_tag(tag, @update_attrs)
      assert tag.custom_genre == false
      assert tag.text == "some updated text"
      assert tag.user_id == 43
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Albums.update_tag(tag, @invalid_attrs)
      assert tag == Albums.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Albums.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Albums.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Albums.change_tag(tag)
    end
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

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Albums.list_songs() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Albums.get_song!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      assert {:ok, %Song{} = song} = Albums.create_song(@valid_attrs)
      assert song.album_id == 42
      assert song.length == "some length"
      assert song.order == 42
      assert song.title == "some title"
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Albums.create_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()
      assert {:ok, %Song{} = song} = Albums.update_song(song, @update_attrs)
      assert song.album_id == 43
      assert song.length == "some updated length"
      assert song.order == 43
      assert song.title == "some updated title"
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Albums.update_song(song, @invalid_attrs)
      assert song == Albums.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Albums.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Albums.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Albums.change_song(song)
    end
  end
end
