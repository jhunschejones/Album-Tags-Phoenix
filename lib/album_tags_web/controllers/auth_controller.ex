defmodule AlbumTagsWeb.AuthController do
  @moduledoc """
  Handles requests and responses to Google OAuth
  """

  use AlbumTagsWeb, :controller
  alias AlbumTags.Accounts
  plug Ueberauth # gives us `request/2` for free

  # catch normal login path
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{
      token: auth.credentials.token,
      email: auth.info.email,
      name: auth.info.name,
      profile_image: auth.info.image,
      provider: "google"
    }

    login(conn, user_params)
  end

  # catch login path when a current user is already on the connection, aka, the
  # user is now signing in using a second window while already signed in to a
  # first window
  def callback(%{assigns: %{current_user: current_user}} = conn, _params) do
    user_params = %{
      token: current_user.token,
      email: current_user.email,
      name: current_user.name,
      profile_image: current_user.profile_image,
      provider: "google"
    }

    # when a current user exists, it means the conn has already gone through the
    # authenticate plug, meaning we have to redirect back farther to get to the
    # original page the user was requesting
    login(conn, user_params, 5)
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Routes.static_page_path(conn, :home))
    |> halt() # this is important otherwise the conn will continue into the controller method before the redirect completes
  end

  defp login(conn, user_params, redirect_steps \\ 2) do
    case Accounts.insert_or_update_user(user_params) do
      {:ok, user} ->
        favorites_id = case AlbumTags.Lists.get_list_by(%{user_id: user.id, title: "My Favorites"}) do
          nil -> nil
          favorites_list -> favorites_list.id
        end

        conn
        |> put_session(:user_id, user.id)
        |> put_session(:favorites_list_id, favorites_id) # stores favorites_list_id on the session so it doesn't have to be queried on every page
        |> configure_session(renew: true) # sends cookie back to client with new identifier
        |> redirect_back(redirect_steps) # redirect to original page before login sequence
      {:error, _reason} ->
        conn
        |> redirect(to: Routes.static_page_path(conn, :home))
    end
  end

  @doc """
  This method can be called to redirect a user to a previous page they were
  visiting. Call with opts `2` to redirect back past the two requests made
  when a user is logging in. Okay to pass in `[]` for opts to redirect to just
  1 previous history entry. Note: a history limit is set in the browser pipeline
  where `NavigationHistory` is plugged.
  """
  def redirect_back(conn, opts) do
    conn
    |> redirect(to: NavigationHistory.last_path(conn, opts))
  end
end
