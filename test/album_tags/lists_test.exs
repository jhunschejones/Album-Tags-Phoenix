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

    test "list_lists/0 returns all lists" do
      list = list_fixture()
      assert Lists.list_lists() == [list]
    end

    test "get_list!/1 returns the list with given id" do
      list = list_fixture()
      assert Lists.get_list!(list.id) == list
    end

    test "create_list/1 with valid data creates a list" do
      assert {:ok, %List{} = list} = Lists.create_list(@valid_attrs)
      assert list.permalink == "some permalink"
      assert list.private == true
      assert list.title == "some title"
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lists.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      list = list_fixture()
      assert {:ok, %List{} = list} = Lists.update_list(list, @update_attrs)
      assert list.permalink == "some updated permalink"
      assert list.private == false
      assert list.title == "some updated title"
    end

    test "update_list/2 with invalid data returns error changeset" do
      list = list_fixture()
      assert {:error, %Ecto.Changeset{}} = Lists.update_list(list, @invalid_attrs)
      assert list == Lists.get_list!(list.id)
    end

    test "delete_list/1 deletes the list" do
      list = list_fixture()
      assert {:ok, %List{}} = Lists.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Lists.get_list!(list.id) end
    end

    test "change_list/1 returns a list changeset" do
      list = list_fixture()
      assert %Ecto.Changeset{} = Lists.change_list(list)
    end
  end
end
