defmodule AlbumTagsWeb.AuthPlug do
  @moduledoc """
  Sets :current_user on the session if a user is logged in
  """
  import Plug.Conn
  alias AlbumTags.Repo
  alias AlbumTags.Accounts.User

  def init(params), do: params

  def call(conn, _params)  do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end
end
