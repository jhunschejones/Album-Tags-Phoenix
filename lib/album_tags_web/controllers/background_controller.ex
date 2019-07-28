defmodule AlbumTagsWeb.BackgroundController do
  use AlbumTagsWeb, :controller
  alias AlbumTags.Albums

  @api_key System.get_env("API_KEY")
  plug :authenticate_request

  def orphans(conn, _params) do
    message = Albums.delete_orphan_records
    render(conn, "show.json", message: message)
  end

  def duplicates(conn, _params) do
    render(conn, "show.json", message: "Duplicates function not yet implemented")
  end

  def invalid(conn, _params) do
    render(conn, "show.json", message: "Invalid function not yet implemented")
  end

  defp authenticate_request(conn, _params) do
    case List.first(get_req_header(conn, "api_key")) do
      @api_key ->
        conn
      _ ->
        conn
        |> put_status(:unauthorized)
        |> render("show.json", message: "Unauthorized")
        |> halt()
    end
  end
end
