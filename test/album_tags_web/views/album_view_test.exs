defmodule AlbumTagsWeb.AlbumViewTest do
  use AlbumTagsWeb.ConnCase
  alias AlbumTagsWeb.AlbumView

  @album_attrs %{apple_album_id: 716394623, apple_url: "https://itunes.apple.com/us/album/the-question/716394623", title: "The Question", artist: "Emery", release_date: "2005-08-02", record_company: "Tooth & Nail (TNN)", cover: "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/{w}x{h}bb.jpeg"}
  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}
  @alt_user_attrs %{name: "Daisy Bear", email: "daisy@dafox.com", provider: "google", token: "test token 2"}

  setup do
    album = album_fixture(@album_attrs)
    {:ok, album: album}
  end

  test "album_cover/1 returns album cover URL", %{album: album} do
    expected_cover = "https://is3-ssl.mzstatic.com/image/thumb/Music4/v4/db/cd/a9/dbcda9bf-6551-a37d-0d57-3c4455b9d8dd/00724386060457.jpg/500x500bb.jpeg"
    assert AlbumView.album_cover(album) == expected_cover
  end

  test "release_year/1 returns just release year", %{album: album} do
    assert AlbumView.release_year(album) == "2005"
  end

  test "release_date/1 returns formatted date", %{album: album} do
    assert AlbumView.release_date(album) == "08/02/2005"
  end

  describe "remove_duplicate_tags/2" do
    setup do
      user = user_fixture(@user_attrs)
      alt_user = user_fixture(@alt_user_attrs)
      tags = [%{text: "Tag One", user_id: alt_user.id}, %{text: "Tag Two", user_id: user.id}, %{text: "Tag One", user_id: user.id}]
      {:ok, user: user, alt_user: alt_user, tags: tags}
    end

    test "prioritizes user's tags", %{user: user, tags: tags} do
      filtered_tags = AlbumView.remove_duplicate_tags(tags, user)

      assert length(filtered_tags) == 2
      assert List.last(filtered_tags).text == "Tag One"
      assert List.last(filtered_tags).user_id == user.id
      assert List.first(filtered_tags).text == "Tag Two"
      assert List.first(filtered_tags).user_id == user.id
    end

    test "returns generally de-duped tags when no user", %{user: user, alt_user: alt_user, tags: tags} do
      filtered_tags = AlbumView.remove_duplicate_tags(tags, nil)

      assert length(filtered_tags) == 2
      assert List.first(filtered_tags).text == "Tag One"
      assert List.first(filtered_tags).user_id == alt_user.id
      assert List.last(filtered_tags).text == "Tag Two"
      assert List.last(filtered_tags).user_id == user.id
    end
  end

  describe "remove_duplicate_connections/2" do
    setup do
      user = user_fixture(@user_attrs)
      alt_user = user_fixture(@alt_user_attrs)
      connections = [%{apple_album_id: 1, connection_owner: alt_user.id}, %{apple_album_id: 2, connection_owner: user.id}, %{apple_album_id: 1, connection_owner: user.id}]
      {:ok, user: user, alt_user: alt_user, connections: connections}
    end

    test "prioritizes user's connections", %{user: user, connections: connections} do
      filtered_connections = AlbumView.remove_duplicate_connections(connections, user)

      assert length(filtered_connections) == 2
      assert List.first(filtered_connections).apple_album_id == 2
      assert List.first(filtered_connections).connection_owner == user.id
      assert List.last(filtered_connections).apple_album_id == 1
      assert List.last(filtered_connections).connection_owner == user.id
    end

    test "returns generally de-duped connections when no user", %{user: user, alt_user: alt_user, connections: connections} do
      filtered_connections = AlbumView.remove_duplicate_connections(connections, nil)

      assert length(filtered_connections) == 2
      assert List.first(filtered_connections).apple_album_id == 1
      assert List.first(filtered_connections).connection_owner == alt_user.id
      assert List.last(filtered_connections).apple_album_id == 2
      assert List.last(filtered_connections).connection_owner == user.id
    end
  end
end
