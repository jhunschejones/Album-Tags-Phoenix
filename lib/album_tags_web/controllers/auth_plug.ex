defmodule AlbumTagsWeb.AuthPlug do
  @moduledoc """
  Sets :current_user on the session if a user is logged in
  """
  import Plug.Conn
  import Phoenix.Controller
  alias AlbumTagsWeb.Router.Helpers, as: Routes
  alias AlbumTags.Accounts

  def init(params), do: params

  def call(conn, _params)  do
    user_id = get_session(conn, :user_id)
    cond do
      # if the user_id exists and the user is in the database
      user = user_id && Accounts.get_user(user_id) ->
        assign(conn, :current_user, user)
      # if the user doesn't exist on the session OR in the database
      true ->
        conn
        |> assign(:current_user, nil)
    end
  end

  @doc """
  If no current user is set, redirect the user to the login path. With this module 
  in the `album_tags_web.ex` controller pipeline, this method can be used as a plug
  by any controllers that require a user to first be logged in.
  """
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> redirect(to: Routes.auth_path(conn, :request, "google"))
    end
  end
end
