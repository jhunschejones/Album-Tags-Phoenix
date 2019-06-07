defmodule AlbumTags.Albums do
  @moduledoc """
  The Albums context.
  """

  import Ecto.Query, warn: false
  alias AlbumTags.Repo
  alias AlbumTags.Albums.{Album, AlbumTag, AlbumConnection, Tag, Song}

  @doc """
  Gets a single album by database id, preloading songs, tags, and lists.
  """
  def get_album!(id) do
    Album
    |> Repo.get!(id)
    # |> Repo.preload([:songs, :tags, :lists])
  end

  @doc """
  Gets a single album by apple_album_id, preloading songs, tags, and lists.
  """
  def get_album_by(apple_album_id) do
    Album
    |> Repo.get_by!(apple_album_id: apple_album_id)
    |> Repo.preload([:songs, :tags, :lists])
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
  Find all albums where a given album_id is either the parent_album OR child_album.
  """
  def get_album_connections(id) do
    parent_query =
      from a in Album,
      join: c in AlbumConnection,
      on: c.parent_album == a.id,
      select: a,
      where: c.child_album == ^id

    child_query =
      from a in Album,
      join: c in AlbumConnection,
      on: c.child_album == a.id,
      select: a,
      where: c.parent_album == ^id,
      union_all: ^parent_query

    Repo.all(child_query)
  end

  @doc """
  Deletes a connection between two albums without deleting either of the albums themselves.
  """
  def delete_album_connection(%AlbumConnection{} = connection) do
    Repo.delete(connection)
  end
end
