defmodule AlbumTagsWeb.StaticPageControllerTest do
  use AlbumTagsWeb.ConnCase, async: true

  @user_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}

  describe "home/2" do
    test "returns the home page when user is authenticated", %{conn: conn} do
      conn = Plug.Test.init_test_session(conn, user_id: user_fixture(@user_attrs).id)
      conn = get(conn, Routes.static_page_path(conn, :home))
      assert html_response(conn, 200) =~ "Welcome to Album Tags"
    end

    test "returns the home page when user is not authenticated", %{conn: conn} do
      conn = get(conn, Routes.static_page_path(conn, :home))
      assert html_response(conn, 200) =~ "Welcome to Album Tags"
    end
  end
end
