defmodule AlbumTagsWeb.TagView do
  use AlbumTagsWeb, :view

  def tags_for_user(tags, user) do
    tags
    |> Enum.filter(fn t -> t.user_id == user.id end) # filter to just this user
    |> Enum.map(fn tagObject -> tagObject.text end) # just return tag text
    |> Jason.encode!()
  end
end
