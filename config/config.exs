# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :album_tags,
  ecto_repos: [AlbumTags.Repo]

# Configures the endpoint
config :album_tags, AlbumTagsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XXXXXX",
  render_errors: [view: AlbumTagsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AlbumTags.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [] }
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "XXXXXX",
  client_secret: "XXXXXX"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
