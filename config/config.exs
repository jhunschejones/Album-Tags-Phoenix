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
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: AlbumTagsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AlbumTags.PubSub, adapter: Phoenix.PubSub.PG2],
  instrumenters: [NewRelic.Phoenix.Instrumenter]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"] }
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("UEBERAUTH_CLIENT_ID"),
  client_secret: System.get_env("UEBERAUTH_CLIENT_SECRET")

config :new_relic_agent, apdex_t: 0.015
# The agent will automatically read this from environment variables
#   app_name: System.get_env("NEW_RELIC_APP_NAME"),
#   license_key: System.get_env("NEW_RELIC_LICENSE_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
