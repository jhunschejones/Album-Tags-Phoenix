defmodule AlbumTagsWeb.ListController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.{Albums, Lists}
  alias Plug.Conn

  plug :authenticate_user when action in [:new, :create, :edit, :update, :index]

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
    lists = Lists.get_user_lists(conn.assigns.current_user.id)
    data_for_page = %{lists: lists, page: "lists_index"}
    render(conn, "index.html", data_for_page)
  end

  # loads tag search results as a list
  def tag_search(conn, %{"search_string" => search_string}) do
    tags = search_string |> URI.decode() |> String.split(",,")

    list = Map.new()
    |> Map.put_new(:title, "Tag Search:")
    |> Map.put_new(:title_tags, tags)
    |> Map.put_new(:albums, Albums.search_by_tags(search_string))
    |> Map.put_new(:user_id, nil)

    data_for_page = %{list: list, page: "show_lists", user: conn.assigns.current_user}
    render(conn, "show.html", data_for_page)
  end

  # loads the list SPA
  def show(conn, %{"id" => list_id}) do
    case Lists.get_list_with_all_assoc(list_id) do
      response when response in [{:error, nil}, nil] ->
        conn
        |> put_status(:not_found)
        |> put_view(AlbumTagsWeb.ErrorView)
        |> render("404.html", %{page: "error"})
      list ->
        data_for_page = %{list: list, page: "show_lists", user: conn.assigns.current_user}
        render(conn, "show.html", data_for_page)
    end
  end

  # creates new list and adds album on xhr POST
  # returns message and new_list
  # does not allow `My Favorites` list creation
  def create(conn, %{"title" => title, "private" => private, "currentAlbum" => apple_album_id}) do
    if title |> String.trim() |> String.upcase() == "MY FAVORITES" do
      message = "The 'My Favorites' list already exists"
      render(Conn.put_status(conn, :bad_request), "show.json", message: message)
    else
      {status, message} = case Lists.create_list(%{
        title: title,
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

      render(Conn.put_status(conn, status), "show.json", message: message)
    end
  end

  # creates new list on xhr POST
  # returns a message
  def create(conn, %{"title" => title, "private" => private}) do
    {status, message, new_list} = case Lists.create_list(%{
      title: title,
      private: private,
      user_id: conn.assigns.current_user.id,
    }) do
      {:ok, new_list} ->
        {:ok, "List successfully created", new_list}
      {:error, response} ->
        Tuple.append(handle_changeset_error(response), nil) # add nil for no new list
    end

    new_list = new_list || nil

    # add favorites_list_id to session to save extra queries
    if new_list && new_list.title == "My Favorites" do
      render(Conn.put_status(Conn.put_session(conn, :favorites_list_id, new_list.id), status), "show.json", message: message, new_list: new_list)
    else
      render(Conn.put_status(conn, status), "show.json", message: message, new_list: new_list)
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

    render(Conn.put_status(conn, status), "show.json", message: message, added_album: added_album)
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

    # update favorites list on session to save extra queries
    render(Conn.put_status(Conn.put_session(conn, :favorites_list_id, favorites_list.id), status), "show.json", message: message)
  end

  # remove album from list on xhr PATCH
  def update(conn, %{"action" => action} = params) when action == "remove_album" do
    %{"albumID" => album_id, "id" => list_id} = params

    {status, message} = case Lists.remove_album_from_list(%{
      album_id: album_id,
      list_id: String.to_integer(list_id),
      user_id: conn.assigns.current_user.id,
    }) do
      {:error, reason} -> {:bad_request, reason}
      _ -> {:ok, "Album successfully removed from list"}
    end

    render(Conn.put_status(conn, status), "show.json", message: message)
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
      {:update_error, reason} ->
        {:bad_request, reason, nil}
      {:error, response} ->
        Tuple.append(handle_changeset_error(response), nil) # add nil for no new list title
    end

    list_title = list_title || nil

    render(Conn.put_status(conn, status), "show.json", message: message, list_title: list_title)
  end

  # deletes a list on xhr DELETE
  def delete(conn, %{"id" => list_id}) do
    case Lists.delete_user_list(%{
      list_id: String.to_integer(list_id),
      user_id: conn.assigns.current_user.id
    }) do
      {:ok, deleted_list} ->
        case deleted_list.title do
          "My Favorites" ->
            render(Conn.put_session(conn, :favorites_list_id, nil), "show.json", message: "List successfully deleted")
          _ ->
            render(conn, "show.json", message: "List successfully deleted")
        end
      {:error, reason} ->
        render(Conn.put_status(conn, :bad_request), "show.json", message: reason)
    end
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
end
