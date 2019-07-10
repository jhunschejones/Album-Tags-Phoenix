defmodule AlbumTags.TestHelpers do
  alias AlbumTags.{Accounts, Albums, Lists}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  def album_fixture(attrs \\ %{}) do
    Albums.create_album!(attrs)
  end

  def connection_fixture(album_one, album_two, user) do
    Albums.create_album_connection(%{parent_album: album_one.id, child_album: album_two.id, user_id: user.id})
  end

  def list_fixture(%{title: title, user_id: user_id, album_id: album_id}) do
    {:ok, list} = Lists.create_list(%{title: title, user_id: user_id})
    Lists.add_album_to_list(%{list_id: list.id, user_id: user_id, album_id: album_id})
    list
  end

  def list_fixture(%{title: title, user_id: user_id}) do
    {:ok, list} = Lists.create_list(%{title: title, user_id: user_id})
    list
  end

  def tag_fixture(%{text: text, user_id: user_id, album_id: album_id}) do
    {:ok, tag} = Albums.find_or_create_tag(%{text: text, user_id: user_id, custom_genre: false})
    Albums.add_tag_to_album(%{album_id: album_id, tag_id: tag.id, user_id: user_id})
    tag
  end
end
