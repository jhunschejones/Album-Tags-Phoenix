defmodule AlbumTagsWeb.ConnectionController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  plug :authenticate_user when action in [:edit]

  def edit(conn, %{"id" => apple_album_id}) do
    album = Albums.get_album_with(apple_album_id, [:connections])
    data_for_page = %{album: album, page: "edit_connections", user: conn.assigns.current_user}
    render(conn, "edit.html", data_for_page)
  end

  def create(conn, params) do
    {status, message} = case params["parentAlbum"] == params["childAlbum"] do
      true ->
        {:bad_request, %{message: "You cannot connect an album to itself"}}
      false ->
        result = Albums.create_album_connection(%{
          parent_album: Albums.find_or_create_album(params["parentAlbum"]).id,
          child_album: Albums.find_or_create_album(params["childAlbum"]).id,
          user_id: conn.assigns.current_user.id
        })
        case result do
          {:ok, _} ->
            {:ok, %{message: "Connection successfully created"}}
          {:error, response} ->
            {element, {reason, _}} = List.first(response.errors)
            case element == :child_album && reason == "has already been taken" do
              true ->
                {:bad_request, %{message: "You cannot connect two albums more than once"}}
              false ->
                {:internal_server_error, %{message: "Unable to create connection"}}
            end
        end
    end
    render(Plug.Conn.put_status(conn, status), "show.json", message: message)
  end

  # # receive connection delete input from form
  # def delete(conn, %{"id" => apple_album_id} = params) do
  #   render(conn, "edit.html", page: nil)
  # end
end
