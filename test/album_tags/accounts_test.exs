defmodule AlbumTags.AccountsTest do
  use AlbumTags.DataCase, async: true

  alias AlbumTags.Accounts

  describe "users" do
    alias AlbumTags.Accounts.User

    @valid_attrs %{name: "Carl Fox", email: "carl@dafox.com", provider: "google", token: "test token 1"}
    @new_attrs %{name: "Daisy Bear", email: "daisy@dafox.com", provider: "google", token: "test token 2"}
    @attrs_missing_email %{name: "McClain Fox", provider: "google", token: "test token 3"}
    @attrs_missing_provider %{name: "McClain Fox", email: "mcclain@dafox.com", token: "test token 3"}
    @attrs_missing_token %{name: "McClain Fox", provider: "google", email: "mcclain@dafox.com"}

    test "insert_or_update_user/1 finds user if one exists" do
      existing_user = user_fixture(@valid_attrs)
      {:ok, found_user} = Accounts.insert_or_update_user(@valid_attrs)
      assert found_user.name == existing_user.name
      assert found_user.email == existing_user.email
    end

    test "insert_or_update_user/1 creates new user if none exists" do
      {:ok, new_user} = Accounts.insert_or_update_user(@new_attrs)
      assert new_user.name == @new_attrs.name
      assert new_user.email == @new_attrs.email
    end

    test "get_user/1 finds a user when one exists" do
      existing_user = user_fixture(@valid_attrs)
      found_user = Accounts.get_user(existing_user.id)
      assert existing_user.name == found_user.name
      assert existing_user.email == found_user.email
    end

    test "get_user/1 returns nil when no user exists" do
      assert Accounts.get_user(12) == nil
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == @valid_attrs.name
      assert user.email == @valid_attrs.email
    end

    test "create_user/1 returns error when missing email" do
      {:error, %{errors: reason}} = Accounts.create_user(@attrs_missing_email)
      assert reason == [email: {"can't be blank", [validation: :required]}]
    end

    test "create_user/1 returns error when missing provider" do
      {:error, %{errors: reason}} = Accounts.create_user(@attrs_missing_provider)
      assert reason == [provider: {"can't be blank", [validation: :required]}]
    end

    test "create_user/1 returns error when missing token" do
      {:error, %{errors: reason}} = Accounts.create_user(@attrs_missing_token)
      assert reason == [token: {"can't be blank", [validation: :required]}]
    end

    test "create_user/1 returns error when email is already used" do
      user_fixture(@valid_attrs)
      {:error, %{errors: reason}} = Accounts.create_user(@valid_attrs)
      assert reason == [email: {"has already been taken", [constraint: :unique, constraint_name: "users_email_index"]}]
    end
  end
end
