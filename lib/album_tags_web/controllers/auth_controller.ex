defmodule AlbumTagsWeb.AuthController do
  @moduledoc """
  Handles requests and responses to Google OAuth
  """

  use AlbumTagsWeb, :controller
  alias AlbumTags.Accounts
  plug Ueberauth # gives us the :request method for free

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{
      token: auth.credentials.token,
      email: auth.info.email,
      provider: "google"
    }
    changeset = Accounts.change_user(user_params)

    login(conn, changeset)
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp login(conn, changeset) do
    case Accounts.insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back")
        |> put_session(:user_id, user.id)
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
