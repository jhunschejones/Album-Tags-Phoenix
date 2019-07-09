defmodule AlbumTags.TestHelpers do
  alias AlbumTags.{Accounts, Albums, Lists}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(attrs)
      |> Accounts.create_user()

    user
  end

  def album_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(attrs)
    |> Albums.create_album!()
  end

  def connection_fixture(album_one, album_two, user) do
    Albums.create_album_connection(%{parent_album: album_one.id, child_album: album_two.id, user_id: user.id})
  end
end
