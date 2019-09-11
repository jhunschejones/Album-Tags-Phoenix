defmodule AlbumTagsWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :album_tags
  use NewRelic.Phoenix.Transaction

  socket "/socket", AlbumTagsWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :album_tags,
    gzip: true,
    only: ~w(css fonts images js favicon.ico robots.txt service-worker.min.js)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_album_tags_3",
    signing_salt: "k+vCu8cY",
    # without max_age the session will expire when browser is closed
    # adding max_age impliments sessions that can span browser sessions
    # remove max_age line to return to browser session length restriction
    max_age: 1209600 # 60*60*24*14

  plug AlbumTagsWeb.Router
end
