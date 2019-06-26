defmodule AlbumTagsWeb.ListController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.{Albums, Lists}

  plug :authenticate_user when action in [:new, :edit, :index]

  def new(conn, %{"album" => apple_album_id}) do
    data_for_page = %{
      album: Albums.get_album_with(apple_album_id, [:lists]),
      user_lists: Lists.get_user_lists(conn.assigns.current_user.id),
      user: conn.assigns.current_user,
      page: "new_lists"
    }

    render(conn, "new.html", data_for_page)
  end

  def edit(conn, %{"id" => apple_album_id}) do
    album = Albums.get_album_with(apple_album_id, [lists: [:albums]])
    data_for_page = %{album: album, page: "edit_lists", user: conn.assigns.current_user}
    render(conn, "edit.html", data_for_page)
  end

  # loads the my-lists page
  def index(conn, _params) do
    lists = Lists.get_user_lists(conn.assigns.current_user)
    data_for_page = %{lists: lists, page: "lists_index"}
    render(conn, "index.html", data_for_page)
  end

  # loads the list SPA
  def show(conn, %{"id" => list_id} = _params) do
    list = Lists.get_list!(list_id)
    data_for_page = %{list: list, page: "show_lists", user: conn.assigns.current_user}
    render(conn, "show.html", data_for_page)
  end

  # creates new list and adds album on xhr POST
  def create(conn, %{"title" => title, "private" => private, "currentAlbum" => apple_album_id}) do
    if title |> String.trim() |> String.upcase() == "MY FAVORITES" do
      message = "The 'My Favorites' list already exists"
      render(Plug.Conn.put_status(conn, :bad_request), "show.json", message: message)
    else
      {status, message} = case Lists.create_list(%{
        title: force_title_case(title),
        private: private,
        user_id: conn.assigns.current_user.id,
      }) do
        {:ok, new_list} ->
          Lists.add_album_to_list(%{
            album_id: Albums.find_or_create_album(apple_album_id).id,
            list_id: new_list.id,
            user_id: conn.assigns.current_user.id,
          })
          {:ok, "List successfully created"}
        {:error, response} ->
          handle_changeset_error(response)
      end

      render(Plug.Conn.put_status(conn, status), "show.json", message: message)
    end
  end

  # creates new list on xhr POST
  def create(conn, %{"title" => title, "private" => private}) do
    if title |> String.trim() |> String.upcase() == "MY FAVORITES" do
      message = "The 'My Favorites' list already exists"
      render(Plug.Conn.put_status(conn, :bad_request), "show.json", message: message)
    else
      {status, message, new_list} = case Lists.create_list(%{
        title: force_title_case(title),
        private: private,
        user_id: conn.assigns.current_user.id,
      }) do
        {:ok, new_list} ->
          {:ok, "List successfully created", new_list}
        {:error, response} ->
          Tuple.append(handle_changeset_error(response), nil) # add nil for no new list
      end

      new_list = new_list || nil

      render(Plug.Conn.put_status(conn, status), "show.json", message: message, new_list: new_list)
    end
  end

  # add album to list on xhr PATCH
  def update(conn, %{"action" => action} = params) when action == "add_album" do
    album_to_add = Albums.find_or_create_album(params["currentAlbum"])

    {status, message, added_album} = case Lists.add_album_to_list(%{
      album_id: album_to_add.id,
      list_id: String.to_integer(params["id"]),
      user_id: conn.assigns.current_user.id,
    }) do
      {:ok, _response} ->
        {:ok, "Album successfully added to list", Albums.album_with_tags(album_to_add)}
      {:error, response} ->
        Tuple.append(handle_changeset_error(response), nil) # add nil for no added_album
    end

    added_album = added_album || nil

    render(Plug.Conn.put_status(conn, status), "show.json", message: message, added_album: added_album)
  end

  # add album to favorites list on xhr PATCH
  def update(conn, %{"action" => action} = params) when action == "add_favorite" do
    favorites_list = Lists.find_or_create_favorites(conn.assigns.current_user.id)

    {status, message} = case Lists.add_album_to_list(%{
      album_id: Albums.find_or_create_album(params["currentAlbum"]).id,
      list_id: favorites_list.id,
      user_id: conn.assigns.current_user.id,
    }) do
      {:ok, _response} ->
        {:ok, "Album successfully added to your favorites"}
      {:error, response} ->
        handle_changeset_error(response)
    end

    render(Plug.Conn.put_status(conn, status), "show.json", message: message)
  end

  # remove album from list on xhr PATCH
  def update(conn, %{"action" => action} = params) when action == "remove_album" do
    %{"albumID" => album_id, "id" => list_id} = params
    Lists.remove_album_from_list(%{
      album_id: album_id,
      list_id: String.to_integer(list_id),
      user_id: conn.assigns.current_user.id,
    })

    render(conn, "show.json", message: "Album successfully removed from list")
  end

  # update list name xhr PATCH
  def update(conn, %{"action" => action} = params) when action == "update_title" do
    {status, message, list_title} = case Lists.update_title(%{
      list_id: params["id"],
      title: params["newTitle"],
      user_id: conn.assigns.current_user.id,
    }) do
      {:ok, response} ->
        {:ok, "List title successfully updated", response.title}
      {:error, response} ->
        Tuple.append(handle_changeset_error(response), nil) # add nil for no new list title
    end

    list_title = list_title || nil

    render(Plug.Conn.put_status(conn, status), "show.json", message: message, list_title: list_title)
  end

  # deletes a list on xhr DELETE
  def delete(conn, %{"id" => list_id}) do
    Lists.delete_user_list(%{
      list_id: String.to_integer(list_id),
      user_id: conn.assigns.current_user.id
    })
    render(conn, "show.json", message: "List successfully deleted")
  end

  defp handle_changeset_error(response) do
    {element, {reason, _}} = List.first(response.errors)

    case {element, reason} do
      {:title, "has already been taken"} ->
        {:bad_request, "You already created a list with that tile"}
      {:album, "has already been taken"} ->
        {:bad_request, "You already added the album to this list"}
      {:title, "should be at least %{count} character(s)"} ->
        {:bad_request, "List titles must be at least two characters long"}
      {:title, "can't be blank"} ->
        {:bad_request, "List titles must be at least two characters long"}
      {:title, "should be at most %{count} character(s)"} ->
        {:bad_request, "List titles cannot be more than sixty characters long"}
      _ ->
        {:internal_server_error, "Unable to modify list as requested"}
    end
  end

  def force_title_case(input_string) do
    not_capitalized = ["a", "an", "and", "the", "for", "but", "yet", "so", "nor", "at", "by", "of", "to", "on"]

    input_string
    |> String.trim()
    |> String.downcase()
    |> String.split()
    |> Enum.with_index()
    |> Enum.map_join(" ", fn {word, index} ->
        word_not_capitalizable = Enum.any?(not_capitalized, &(&1 == word))
        case index != 0 && word_not_capitalizable do
          true -> word
          false -> String.capitalize(word)
        end
      end)
  end
end
