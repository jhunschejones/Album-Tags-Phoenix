defmodule AlbumTags.Lists do
  @moduledoc """
  The Lists context.
  """

  import Ecto.{Query, UUID}, warn: false
  alias AlbumTags.Repo
  alias AlbumTags.Lists.{List, AlbumList}

  @doc """
  Preloads lists for a given, associated module (like an Album)
  """
  def with_lists(module) do
    Repo.preload(module, [lists: [:user]])
  end

  def with_lists_and_albums(module) do
    Repo.preload(module, [lists: [:user, :albums]])
  end

  def get_list_by(attrs) do
    Repo.get_by(List, attrs)
  end

  def get_list_with_all_assoc(list_id) do
    try do
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
    rescue
      Ecto.Query.CastError -> {:error, nil}
    end
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
    try do
      List
      |> Repo.get_by(%{id: list_id, user_id: user_id})
      |> List.changeset(%{title: title})
      |> Repo.update()
    rescue
      FunctionClauseError ->
        case get_list_by(%{id: list_id}).user_id == user_id do
          true ->
            {:update_error, "Unable to update list title"}
          false ->
            {:update_error, "You can't change the title of someone else's list"}
        end
    end
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
    try do
      AlbumList
      |> Repo.get_by(attrs)
      |> Repo.delete()
    rescue
      FunctionClauseError ->
        case get_list_by(%{id: attrs.list_id}).user_id == attrs.user_id do
          true ->
            {:error, "Unable to remove album from list"}
          false ->
            {:error, "You can't remove an album from someone else's list"}
        end
    end
  end

  @doc """
  Deletes a List.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_list(%{list_id: list_id, user_id: user_id}) do
    try do
      List
      |> Repo.get_by(%{id: list_id, user_id: user_id})
      |> Repo.delete()
    rescue
      FunctionClauseError ->
        case get_list_by(%{id: list_id}).user_id == user_id do
          true ->
            {:error, "Unable to delete list list"}
          false ->
            {:error, "You can't delete someone else's list"}
        end
    end
  end
end
