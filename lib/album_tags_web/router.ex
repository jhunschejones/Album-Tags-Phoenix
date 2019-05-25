defmodule AlbumTagsWeb.Router do
  use AlbumTagsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AlbumTagsWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", AlbumTagsWeb do
    pipe_through :api

    get "/apple/search/", AppleMusicController, :search
    get "/apple/details/:id", AppleMusicController, :details
  end
end
