defmodule AlbumTags.Albums do
  @moduledoc """
  The Albums context.
  """

  import Ecto.Query, warn: false
  alias AlbumTags.Repo
  alias AlbumTags.Albums.{Album, AlbumTag, AlbumConnection, Tag, Song}
  alias AlbumTags.Lists


  @doc """
  Preloads album and tags for a given, associated module (like a List)
  """
  def with_albums_and_tags(module) do
    Repo.preload(module, [albums: [:tags]])
  end

  @doc """
  Gets a single album by apple_album_id
  """
  def get_existing_album_with_tags(apple_album_id) do
    Album
    |> Repo.get_by(apple_album_id: apple_album_id)
    |> Repo.preload([tags: [:user]])
  end

  @doc """
  Gets a single album by apple_album_id, include associations if they exist.
  """
  def get_album_with_all_associations(apple_album_id) do
    case Repo.get_by(Album, apple_album_id: apple_album_id) do
      nil ->
        {:error, "No album found"}
      album ->
        get_album_associations(album)
    end
  end

  def get_album_associations(%Album{} = album) do
    album
    |> Repo.preload([:songs, :tags])
    |> Lists.with_lists()
    |> get_album_connections()
  end

  @doc """
  Creates a album.

  ## Examples

      iex> create_album(%{field: value})
      {:ok, %Album{}}

      iex> create_album(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_album(attrs \\ %{}) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Adds a tag to an album, keeping track of the user who made the association.
  """
  def add_tag_to_album(attrs \\ %{}) do
    %AlbumTag{}
    |> AlbumTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Removes an album-tag relationship but does not delete either the album or the tag.
  """
  def remove_tag_from_album(%AlbumTag{} = album_tag) do
    Repo.delete(album_tag)
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  @doc """
  Creates multiple songs associated with an album.
  """
  def create_songs(songs, album) do
    song_changesets = Enum.map(songs, fn x ->
      Song.changeset(%Song{}, Map.put_new(x, :album_id, album.id)).changes
    end)

    Repo.insert_all(Song, song_changesets)
  end

  @doc """
  Creates a connection between two albums, keeping track of the user who created the connection.
  """
  def create_album_connection(attrs \\ %{}) do
    %AlbumConnection{}
    |> AlbumConnection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Find all albums where the id of the given album is either the parent_album OR child_album.
  """
  def get_album_connections(%Album{} = album) do
    parent_query =
      from a in Album,
      join: c in AlbumConnection,
      on: c.parent_album == a.id,
      select: {a, c.user_id},
      where: c.child_album == ^album.id

    child_query =
      from a in Album,
      join: c in AlbumConnection,
      on: c.child_album == a.id,
      select: {a, c.user_id},
      where: c.parent_album == ^album.id,
      union: ^parent_query

    results = Enum.map(Repo.all(child_query), fn x -> 
      {connected_album, user_id} = x
      Map.put_new(connected_album, :connection_owner, user_id)
    end)
    %Album{album | connections: results}
  end

  @doc """
  Deletes a connection between two albums without deleting either of the albums themselves.
  """
  def delete_album_connection(%AlbumConnection{} = connection) do
    Repo.delete(connection)
  end
end
