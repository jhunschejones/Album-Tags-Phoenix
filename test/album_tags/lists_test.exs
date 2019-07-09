defmodule AlbumTags.ListsTest do
  use AlbumTags.DataCase

  alias AlbumTags.Lists

  describe "lists" do
    alias AlbumTags.Lists.List

    @valid_attrs %{permalink: "some permalink", private: true, title: "some title"}
    @update_attrs %{permalink: "some updated permalink", private: false, title: "some updated title"}
    @invalid_attrs %{permalink: nil, private: nil, title: nil}

    def list_fixture(attrs \\ %{}) do
      {:ok, list} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Lists.create_list()

      list
    end

    # test "list_lists/0 returns all lists" do
    #   list = list_fixture()
    #   assert Lists.list_lists() == [list]
    # end
  end
end
