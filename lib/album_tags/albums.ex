defmodule AlbumTags.Albums do
  @moduledoc """
  The Albums context.
  """

  import Ecto.Query, warn: false
  alias AlbumTags.Repo
  alias AlbumTags.Albums.{Album, AlbumTag, AlbumConnection, Tag, Song}
  alias AlbumTags.Lists
  alias Jason

  @doc """
  Preloads album and tags for a given, associated module (like a List)
  """
  def with_albums_and_tags(module) do
    Repo.preload(module, [albums: [tags: [:user]]])
  end

  @doc """
  Includes tags and their associated users for an album
  """
  def album_with_tags(%Album{} = album) do
    album
    |> Repo.preload([tags: [:user]])
  end

  @doc """
  Includes lists and their associated users for an album
  """
  def album_with_lists(%Album{} = album) do
    album
    |> Lists.with_lists()
  end

  def album_with_lists_and_albums(%Album{} = album) do
    album
    |> Lists.with_lists_and_albums()
  end

  @doc """
  Includes all associations for an album
  """
  def album_with_all_associations(%Album{} = album) do
    album
    |> Repo.preload([:songs, :tags])
    |> Lists.with_lists()
    |> get_album_connections()
  end

  @doc """
  Includes connections and their associated users for an album
  """
  def album_with_connections(%Album{} = album) do
    album
    |> get_album_connections()
  end

  def get_album_with(apple_album_id, resources \\ []) do
    try do
      case Repo.get_by(Album, apple_album_id: apple_album_id) do
        nil ->
          case resources do
            # don't add the album to the database when it's just loaded on the album page
            [] ->
              get_apple_album_details(apple_album_id)
            [_] ->
              apple_data = get_apple_album_details(apple_album_id)

              apple_data
              |> Map.from_struct()
              |> create_album!()
              |> create_songs(apple_data.songs)
              |> Map.put(:tags, [])
              |> Map.put(:connections, [])
              |> Map.put(:lists, [])
          end
        album ->
          case resources do
            [:tags] ->
              album_with_tags(album)
            [:connections] ->
              album_with_connections(album)
            [:lists] ->
              album_with_lists(album)
            [lists: [:albums]] ->
              album_with_lists_and_albums(album)
            _ ->
              album_with_all_associations(album)
          end
      end
    rescue
      Ecto.Query.CastError -> {:error, nil}
    end
  end

  @doc """
  Gets an album from the apple music api and returns an Album struct
  """
  def get_apple_album_details(apple_album_id) do
    HTTPoison.get!("https://api.music.apple.com/v1/catalog/us/albums/#{apple_album_id}", [{"Accept", "application/json"}, {"Authorization", "Bearer #{System.get_env("APPLE_MUSIC_TOKEN")}"}])
    |> map_raw_album_data_to_album_struct()
  end

  defp map_raw_album_data_to_album_struct(apple_data) do
    try do
      album = apple_data.body
      |> Jason.decode!
      |> Map.get("data")
      |> List.first()

      %Album{
        apple_album_id: String.to_integer(album["id"]),
        apple_url: album["attributes"]["url"],
        title: album["attributes"]["name"],
        artist: album["attributes"]["artistName"],
        release_date: album["attributes"]["releaseDate"],
        record_company: album["attributes"]["recordLabel"],
        songs: isolate_song_data(album["relationships"]["tracks"]["data"]),
        cover: album["attributes"]["artwork"]["url"],
        tags: [],
        connections: [],
        lists: []
      }
    rescue
      FunctionClauseError -> {:error, nil}
    end
  end

  defp isolate_song_data(all_songs) when is_nil(all_songs), do: []
  defp isolate_song_data(all_songs) do
    all_songs
    |> Enum.map(fn song ->
      %{
        name: song["attributes"]["name"],
        duration: milliseconds_to_time(song["attributes"]["durationInMillis"]),
        track_number: song["attributes"]["trackNumber"],
        preview: List.first(song["attributes"]["previews"])["url"]
      } end)
  end

  defp milliseconds_to_time(millis) do
    total_seconds = Integer.floor_div(millis, 1000)
    minutes = Integer.floor_div(total_seconds,  60)
    seconds = total_seconds - (minutes * 60)

    case length(Integer.digits(seconds)) < 2 do
      true  -> "#{minutes}:0#{seconds}"
      false -> "#{minutes}:#{seconds}"
    end
  end

  @doc """
  Creates a album.

  ## Examples

      iex> create_album(%{field: value})
      {:ok, %Album{}}

      iex> create_album(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_album!(attrs \\ %{}) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert!()
  end

  def find_or_create_album(apple_album_id) do
    case Repo.get_by(Album, apple_album_id: apple_album_id) do
      nil ->
        apple_data = get_apple_album_details(apple_album_id)

        apple_data
        |> Map.from_struct()
        |> create_album!()
        |> create_songs(apple_data.songs)
      album ->
        album
    end
  end

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_tag(%{text: text, user_id: user_id, custom_genre: custom_genre}) do
    case Repo.get_by(Tag, %{text: text, user_id: user_id, custom_genre: custom_genre}) do
      nil ->
        create_tag(%{text: text, user_id: user_id, custom_genre: custom_genre})
      tag ->
        {:ok, tag}
    end
  end

  def search_by_tags(search_string) do
    searched_tags = search_string
    |> URI.decode()
    |> String.split(",,")

    query =
      from t in Tag,
      join: at in AlbumTag,
      on: at.tag_id == t.id,
      join: a in Album,
      on: at.album_id == a.id,
      # Replace existing `where` statement with this one to make this a user-specific search. NOTE: requires user_id as a param
      # where: t.text in ^searched_tags and t.user_id == ^user_id,
      where: t.text in ^searched_tags,
      select: a,
      distinct: [a.apple_album_id]

    Repo.all(query)
    |> Repo.preload(tags: [:user])
    |> Enum.filter(fn a ->
      Enum.all?(searched_tags, fn t ->
        Enum.member?(Enum.map(a.tags, &(&1.text)), t)
      end)
    end)
  end

  @doc """
  Adds a tag to an album, keeping track of the user who made the association.
  """
  def add_tag_to_album(attrs \\ %{}) do
    %AlbumTag{}
    |> AlbumTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Removes an album-tag relationship but does not delete either the album or the tag.
  """
  def remove_tag_from_album(attrs) do
    case AlbumTag |> Repo.get_by(attrs) do
      nil ->
        {:error, "Unable to remove tag from album"}
      album_tag ->
        Repo.delete(album_tag)
        {:ok, "Tag removed from album"}
    end
  end

  @doc """
  Creates multiple songs associated with an album. NOTE: in order to function in
  an album pipeline, this only returns the album with the input song data, not
  the actual song structs from the database. This should not affect UI performance,
  but is important to know as it may not be expected behavior.
  """
  def create_songs(album, songs) do
    song_changesets = Enum.map(songs, fn x ->
      Song.changeset(%Song{}, Map.put_new(x, :album_id, album.id)).changes
    end)
    Repo.insert_all(Song, song_changesets)

    %Album{album | songs: songs}
  end

  @doc """
  Creates a connection between two albums, keeping track of the user who created the connection.
  """
  def create_album_connection(attrs \\ %{}) do
    %AlbumConnection{}
    |> AlbumConnection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Find all albums where the id of the given album is either the parent_album OR child_album.
  """
  def get_album_connections(%Album{} = album) do
    parent_query =
      from a in Album,
      join: c in AlbumConnection,
      on: c.parent_album == a.id,
      select: {a, c.user_id},
      where: c.child_album == ^album.id

    child_query =
      from a in Album,
      join: c in AlbumConnection,
      on: c.child_album == a.id,
      select: {a, c.user_id},
      where: c.parent_album == ^album.id,
      union: ^parent_query

    results = Enum.map(Repo.all(child_query), fn x ->
      {connected_album, user_id} = x
      Map.put_new(connected_album, :connection_owner, user_id)
    end)
    %Album{album | connections: results}
  end

  @doc """
  Deletes a connection between two albums without deleting either of the albums themselves.
  """
  def delete_album_connection(attrs) do
    case AlbumConnection |> Repo.get_by(attrs) do
      nil ->
        {:error, "Unable to delete connection"}
      connection ->
        Repo.delete(connection)
        {:ok, "Connection deleted"}
    end
  end

  # ====== Start methods for background controller & DB maintenance ======

  def delete_orphan_records(cutoff_naive_date_time \\ nil) do
    cutoff = cutoff_naive_date_time || one_day_ago()

    album_results = Album
    |> Repo.all()
    |> Repo.preload([:tags, :lists])
    |> Stream.map(fn album -> get_album_connections(album) end)
    |> Stream.filter(fn album ->
        album.connections == [] && album.lists == [] && album.tags == [] && older_than_cutoff?(album, cutoff)
      end)
    |> Enum.map(fn album -> Repo.delete!(album) end)

    tag_results = Tag
    |> Repo.all()
    |> Repo.preload([:albums])
    |> Stream.filter(fn tag ->
        tag.albums == [] && older_than_cutoff?(tag, cutoff)
      end)
    |> Enum.map(fn tag -> Repo.delete!(tag) end)

    "Deleted #{length(album_results)} orphan albums and #{length(tag_results)} orphan tags"
  end

  defp older_than_cutoff?(db_record, cutoff_naive_date_time) do
    NaiveDateTime.compare(db_record.inserted_at, cutoff_naive_date_time) == :lt
  end

  defp one_day_ago do
    NaiveDateTime.utc_now() |> NaiveDateTime.add(-86400, :second)
  end

  def cache_invalid_apple_album_ids do
    Task.async(fn ->
      {:ok, client} = Exredis.start_link
      results = find_invalid_apple_album_ids()

      Exredis.Api.set(client, "invalid_apple_album_ids", Enum.join(results, ", "))
      Exredis.Api.set(client, "invalid_apple_album_ids:timestamp", NaiveDateTime.to_string(NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)))
      Exredis.stop(client)
    end)

    "Searching for invalid Apple Album ID's"
  end

  def find_invalid_apple_album_ids do
    Album
    |> Repo.all()
    |> Stream.filter(fn album ->
        !valid_apple_album_id?(album.apple_album_id)
      end)
    |> Enum.map(fn album -> album.apple_album_id end)
  end

  def retrieve_invalid_apple_album_ids do
    {:ok, client} = Exredis.start_link
    invalid_ids = Exredis.Api.get(client, "invalid_apple_album_ids")
    timestamp = Exredis.Api.get(client, "invalid_apple_album_ids:timestamp")
    Exredis.stop(client)

    %{invalid_apple_album_ids: String.split(invalid_ids, ", "), timestamp: timestamp}
  end

  defp valid_apple_album_id?(apple_album_id) do
    HTTPoison.get!("https://api.music.apple.com/v1/catalog/us/albums/#{apple_album_id}", [{"Accept", "application/json"}, {"Authorization", "Bearer #{System.get_env("APPLE_MUSIC_TOKEN")}"}]).status_code == 200
  end

  def retrieve_duplicate_albums do
    Album
    |> Repo.all()
    |> collect_duplicate_albums([])
  end

  defp collect_duplicate_albums([], duplicate_albums), do: duplicate_albums

  defp collect_duplicate_albums(remaining_albums, previous_duplicate_albums) do
    [current_album | remaining_albums] = remaining_albums

    duplicate_albums = remaining_albums
    |> Enum.filter(fn album -> are_duplicates?(album, current_album) end)
    |> add_current_album_if_duplicate(current_album)
    |> Enum.concat(previous_duplicate_albums)

    collect_duplicate_albums(remaining_albums, duplicate_albums)
  end

  defp add_current_album_if_duplicate(duplicate_albums, current_album) do
    case length(duplicate_albums) do
      0 ->
        duplicate_albums
      _ ->
        [current_album | duplicate_albums]
    end
  end

  defp are_duplicates?(album_one, album_two) do
    same_title = comparable_string(album_one.title) == comparable_string(album_two.title)
    same_artist = comparable_string(album_one.artist) == comparable_string(album_two.artist)

    same_title && same_artist
  end

  defp comparable_string(input_string) do
    input_string
    |> String.upcase()
    |> String.replace("A", "")
    |> String.replace("AND", "")
    |> String.replace("THE", "")
  end
end
