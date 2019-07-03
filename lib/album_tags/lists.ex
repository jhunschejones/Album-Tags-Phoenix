defmodule AlbumTags.Lists do
  @moduledoc """
  The Lists context.
  """

  import Ecto.{Query, UUID}, warn: false
  alias AlbumTags.Repo

  alias AlbumTags.Lists.{List, AlbumList}
  alias AlbumTags.Albums

  @doc """
  Preloads lists for a given, associated module (like an Album)
  """
  def with_lists(module) do
    Repo.preload(module, [lists: [:user]])
  end

  def with_lists_and_albums(module) do
    Repo.preload(module, [lists: [:user, :albums]])
  end

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists()
      [%List{}, ...]

  """
  def list_lists do
    List
    |> Repo.all()
  end

  @doc """
  Gets a single list.
  """
  def get_list!(id) do
    List
    |> Repo.get!(id)
    |> Albums.with_albums_and_tags()
  end

  def get_list_by(attrs) do
    List
    |> Repo.get_by(attrs)
  end

  def get_list_with_all_assoc(list_id) do
    # optimized to run as one SQL query
    query =
      from list in List,
      where: list.id == ^list_id,
      left_join: list_user in assoc(list, :user),
      left_join: albums in assoc(list, :albums),
      left_join: tags in assoc(albums, :tags),
      left_join: user in assoc(tags, :user),
      preload: [user: list_user, albums: {albums, tags: {tags, user: user}}]

    Repo.one(query)
  end

  @doc """
  Gets all lists associated with a specific user_id
  """
  def get_user_lists(user_id) do
    # optimized to run as one SQL query
    query =
      from list in List,
      where: list.user_id == ^user_id,
      left_join: albums in assoc(list, :albums),
      preload: [albums: albums]

    Repo.all(query)
  end

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(%{field: value})
      {:ok, %List{}}

      iex> create_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(attrs \\ %{}) do
    attrs = Map.put_new(attrs, :permalink, Ecto.UUID.generate())

    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_favorites(user_id) do
    case Repo.get_by(List, [user_id: user_id, title: "My Favorites"]) do
      nil ->
        {:ok, favorites_list} = create_list(%{
          title: "My Favorites",
          private: false,
          user_id: user_id,
        })
        favorites_list
      favorites_list ->
        favorites_list
    end
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_title(%{list_id: list_id, title: title, user_id: user_id}) do
    List
    |> Repo.get_by(%{id: list_id, user_id: user_id})
    |> List.changeset(%{title: title})
    |> Repo.update()
  end

  @doc """
  Adds an album to a list, keeping track of the user who did the modification.
  """
  def add_album_to_list(attrs \\ %{}) do
    %AlbumList{}
    |> AlbumList.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Removes an album from a list without deleting the album or the list.
  """
  def remove_album_from_list(attrs) do
    AlbumList
    |> Repo.get_by(attrs)
    |> Repo.delete()
  end

  @doc """
  Deletes a List.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_list(%{list_id: id, user_id: user_id}) do
    List
    |> Repo.get_by(%{id: id, user_id: user_id})
    |> Repo.delete()
  end
end
