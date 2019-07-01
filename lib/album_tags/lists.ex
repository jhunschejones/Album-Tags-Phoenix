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

  # def get_associated_tags_for_user(album_ids, user_id) do
  #   query =
  #     from t in Albums.Tag,
  #     join: a in assoc(t, :albums),
  #     preload: [:user],
  #     where: a.id in ^album_ids and t.user_id == ^user_id,
  #     select: {a.id, t}

  #   Repo.all(query)
  # end

  def get_list_with_user!(list_id, user_id) do
    # tags_preloader = fn album_ids ->
    #   get_associated_tags_for_user(album_ids, user_id)
    # end

    # problem is this only loads albums with tags by this user, it doesn't
    # limit the tags loaded to just this user's tags
    # query =
    #   from l in List,
    #   join: a in assoc(l, :albums),
    #   join: t in assoc(a, :tags),
    #   join: u in assoc(t, :user),
    #   preload: [:albums, albums: :tags],
    #   where: l.id == ^list_id,
    #   select: l

    # Repo.all(query)

    List
    |> Repo.get!(list_id)
    |> Repo.preload(:user)
    |> Albums.with_albums_and_tags()
  end

  @doc """
  Gets all lists associated with a specific user_id
  """
  def get_user_lists(user_id) do
    query =
      from l in List,
      preload: [albums: [:tags]],
      where: l.user_id == ^user_id

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
