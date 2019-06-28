defmodule AlbumTagsWeb.Router do
  use AlbumTagsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    # plug :fetch_flash
    plug :protect_from_forgery
    # plug :put_secure_browser_headers, %{"content-security-policy" => "default-src 'self'; script-src 'self' https://cdn.jsdelivr.net/npm/vue 'unsafe-inline'; connect-src 'self'; img-src 'self' is1-ssl.mzstatic.com/image/ is2-ssl.mzstatic.com/image/ is3-ssl.mzstatic.com/image/ is4-ssl.mzstatic.com/image/ is5-ssl.mzstatic.com/image/ is6-ssl.mzstatic.com/image/ is7-ssl.mzstatic.com/image/ is8-ssl.mzstatic.com/image/ is9-ssl.mzstatic.com/image/; style-src 'self' 'unsafe-inline' fonts.googleapis.com/icon; font-src 'self' fonts.gstatic.com/s/materialicons/;"}
    plug :put_secure_browser_headers, %{"content-security-policy" => "default-src * 'unsafe-eval' 'unsafe-inline'"}
    plug NavigationHistory.Tracker, history_size: 6 # limit to 6 entries needed to redirect prior to login sequence
    plug AlbumTagsWeb.AuthPlug
  end

  pipeline :browser_no_csrf do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :put_secure_browser_headers, %{"content-security-policy" => "default-src 'self'; script-src 'self' https://cdn.jsdelivr.net/npm/vue 'unsafe-inline'; connect-src 'self'; img-src 'self' is1-ssl.mzstatic.com/image/ is2-ssl.mzstatic.com/image/ is3-ssl.mzstatic.com/image/ is4-ssl.mzstatic.com/image/ is5-ssl.mzstatic.com/image/ is6-ssl.mzstatic.com/image/ is7-ssl.mzstatic.com/image/ is8-ssl.mzstatic.com/image/ is9-ssl.mzstatic.com/image/; style-src 'self' 'unsafe-inline' fonts.googleapis.com/icon; font-src 'self' fonts.gstatic.com/s/materialicons/;"}
    plug :put_secure_browser_headers, %{"content-security-policy" => "default-src * 'unsafe-eval' 'unsafe-inline'"}
    plug NavigationHistory.Tracker, history_size: 6 # limit to 6 entries needed to redirect prior to login sequence
    plug AlbumTagsWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AlbumTagsWeb do
    pipe_through :browser

    get "/", StaticPageController, :home
    get "/tags/search/:search_string", ListController, :tag_search
    resources "/albums", AlbumController, only: [:show]
    resources "/tags", TagController, only: [:create, :edit, :delete]
    resources "/connections", ConnectionController, only: [:new, :create, :edit, :delete]
    resources "/lists", ListController, only: [:index, :show, :new, :create, :edit, :update, :delete]
  end

  scope "/api", AlbumTagsWeb do
    pipe_through :api

    get "/apple/search/", AppleMusicController, :search
    get "/apple/details/:id", AppleMusicController, :details
  end

  scope "/auth", AlbumTagsWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Ignore csrf tokens for logout rout only. This prevents users from seeing an
  # error if they are authenticated in two windows, log out in one, then try to
  # log out in the second.
  scope "/auth", AlbumTagsWeb do
    pipe_through :browser_no_csrf

    delete "/logout", AuthController, :logout
  end
end
