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
    duplicate_albums = Albums.retrieve_duplicate_albums |> Enum.map(&(&1.apple_album_id))
    message = "Found #{length(duplicate_albums)} duplicate albums: #{Enum.join(duplicate_albums, ", ")}"

    render(conn, "show.json", message: message)
  end

  def cache_invalid(conn, _params) do
    message = Albums.cache_invalid_apple_album_ids
    render(conn, "show.json", message: message)
  end

  def fetch_invalid(conn, _params) do
    message = case Albums.retrieve_invalid_apple_album_ids do
      %{invalid_apple_album_ids: [""], timestamp: timestamp} ->
        "#{timestamp} - No invalid Apple Album ID's found"
      %{invalid_apple_album_ids: invalid_apple_album_ids, timestamp: timestamp} ->
        "#{timestamp} - Invalid Apple Album ID's: #{invalid_apple_album_ids}"
    end

    render(conn, "show.json", message: message)
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
