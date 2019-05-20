defmodule AlbumTags.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string, default: "Unknown User"
    field :email, :string
    field :provider, :string
    field :token, :string
    field :profile_image, :string, default: ""
    has_many :tags, AlbumTags.Albums.Tag, on_delete: :delete_all
    has_many :lists, AlbumTags.Lists.List, on_delete: :delete_all
    has_many :album_connections, AlbumTags.Albums.AlbumConnection, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :provider, :token, :profile_image])
    |> validate_required([:email, :provider, :token])
  end
end
