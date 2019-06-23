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
      provider: "google"
    }
    changeset = Accounts.change_user(user_params)

    login(conn, changeset)
  end

  # catch login path when a current user is already on the connection, aka, the
  # user is now signing in using a second window while already signed in to a
  # first window
  def callback(%{assigns: %{current_user: current_user}} = conn, _params) do
    user_params = %{
      token: current_user.token,
      email: current_user.email,
      provider: "google"
    }
    changeset = Accounts.change_user(user_params)

    # when a current user exists, it means the conn has already gone through the
    # authenticate plug, meaning we have to recirect back farther to get to the
    # origional page the user was requesting
    login(conn, changeset, 5)
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp login(conn, changeset, redirect_steps \\ 2) do
    case Accounts.insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back")
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true) # sends cookie back to client with new identifier
        |> redirect_back(redirect_steps) # redirect to original page before login sequence
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: Routes.page_path(conn, :index))
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
