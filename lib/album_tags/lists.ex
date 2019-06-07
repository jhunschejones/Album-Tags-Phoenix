defmodule AlbumTags.Lists do
  @moduledoc """
  The Lists context.
  """

  import Ecto.Query, warn: false
  alias AlbumTags.Repo

  alias AlbumTags.Lists.List
  alias AlbumTags.Lists.AlbumList

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

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!(123)
      %List{}

      iex> get_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list!(id) do
    List
    |> Repo.get!(id)
    |> Repo.preload([albums: [:tags]])
  end

  @doc """
  Gets all lists associated with a specific user_id
  """
  def get_list_by(%{user_id: user_id}) do
    List
    |> Repo.get_by!(user_id: user_id)
    |> Repo.preload([albums: [:tags]])
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
    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
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
  def remove_album_from_list(%AlbumList{} = album_list) do
    Repo.delete(album_list)
  end

  @doc """
  Deletes a List.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{source: %List{}}

  """
  def change_list(%List{} = list) do
    List.changeset(list, %{})
  end
end
