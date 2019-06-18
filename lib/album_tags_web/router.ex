defmodule AlbumTagsWeb.Router do
  use AlbumTagsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NavigationHistory.Tracker, history_size: 3 # limit to 3 entries needed to redirect prior to login sequence
    plug AlbumTagsWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AlbumTagsWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/albums", AlbumController, only: [:show]
    resources "/tags", TagController, only: [:index, :create, :edit, :delete]
    resources "/connections", ConnectionController, only: [:create, :edit, :delete]
    # resources "/lists", ConnectionController, only: [:index, :show, :create, :edit, :update, :delete]
  end

  # Other scopes may use custom stacks.
  scope "/api", AlbumTagsWeb do
    pipe_through :api

    get "/apple/search/", AppleMusicController, :search
    get "/apple/details/:id", AppleMusicController, :details
  end

  scope "/auth", AlbumTagsWeb do #RanqWeb is app namespace
     pipe_through :browser

     get "/:provider", AuthController, :request
     get "/:provider/callback", AuthController, :callback
     delete "/logout", AuthController, :logout
 end
end
