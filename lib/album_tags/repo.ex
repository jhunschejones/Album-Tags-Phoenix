defmodule AlbumTags.Repo do
  use Ecto.Repo,
    otp_app: :album_tags,
    adapter: Ecto.Adapters.Postgres
end
