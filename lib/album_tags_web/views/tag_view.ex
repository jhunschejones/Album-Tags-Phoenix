defmodule AlbumTagsWeb.TagView do
  use AlbumTagsWeb, :view

  def tags_for_user(tags, user) do
    tags
    |> Enum.filter(fn t -> t.user_id == user.id end) # filter to just this user
    |> Enum.map(fn tagObject -> %{text: tagObject.text, tag_id: tagObject.id} end) # just return tag text and id
    |> Jason.encode!()
  end

  def render("show.json", params) do
    %{
      message: params[:message],
      tag_id: params[:tag_id]
    }
  end
end
