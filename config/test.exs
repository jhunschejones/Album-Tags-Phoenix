use Mix.Config

# Configure your database
config :album_tags, AlbumTags.Repo,
  username: "jjones",
  password: "",
  database: "album_tags_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :album_tags, AlbumTagsWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
