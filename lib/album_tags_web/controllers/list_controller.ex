defmodule AlbumTagsWeb.ListController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  plug :authenticate_user when action in [:new, :edit]

  def new(conn, %{"parent_album" => apple_album_id}) do
    album = Albums.get_album_with(apple_album_id, [:lists])
    data_for_page = %{album: album, page: "new_lists", user: conn.assigns.current_user}
    render(conn, "new.html", data_for_page)
  end

  def edit(conn, %{"id" => apple_album_id}) do
    album = Albums.get_album_with(apple_album_id, [:lists])
    data_for_page = %{album: album, page: "edit_lists", user: conn.assigns.current_user}
    render(conn, "edit.html", data_for_page)
  end

  # loads the my-lists page
  # def index(conn, params \\ %{}) do
  #   render(conn, "index.html")
  # end

  # loads the list SPA
  # def show(conn, params \\ %{}) do
  #   render(conn, "show.html")
  # end

  # creates new list on xhr POST
  # def create(conn, params \\ %{}) do
  #   render(conn, "show.json", message: message)
  # end

  # updates a list on xhr PATCH
  # def update(conn, params \\ %{}) do
  #   render(conn, "show.json", message: message)
  # end

  # deletes a list on xhr DELETE
  # def delete(conn, params \\ %{}) do
  #   render(conn, "show.json", message: message)
  # end
end
