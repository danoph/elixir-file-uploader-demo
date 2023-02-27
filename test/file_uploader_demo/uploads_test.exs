defmodule FileUploaderDemo.UploadsTest do
  use FileUploaderDemo.DataCase

  alias FileUploaderDemo.Uploads

  describe "uploads" do
    alias FileUploaderDemo.Uploads.Upload

    import FileUploaderDemo.UploadsFixtures

    @invalid_attrs %{filename: nil}

    test "list_uploads/0 returns all uploads" do
      upload = upload_fixture()
      assert Uploads.list_uploads() == [upload]
    end

    test "get_upload!/1 returns the upload with given id" do
      upload = upload_fixture()
      assert Uploads.get_upload!(upload.id) == upload
    end

    test "create_upload/1 with valid data creates a upload" do
      valid_attrs = %{filename: "some filename"}

      assert {:ok, %Upload{} = upload} = Uploads.create_upload(valid_attrs)
      assert upload.filename == "some filename"
    end

    test "create_upload/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Uploads.create_upload(@invalid_attrs)
    end

    test "update_upload/2 with valid data updates the upload" do
      upload = upload_fixture()
      update_attrs = %{filename: "some updated filename"}

      assert {:ok, %Upload{} = upload} = Uploads.update_upload(upload, update_attrs)
      assert upload.filename == "some updated filename"
    end

    test "update_upload/2 with invalid data returns error changeset" do
      upload = upload_fixture()
      assert {:error, %Ecto.Changeset{}} = Uploads.update_upload(upload, @invalid_attrs)
      assert upload == Uploads.get_upload!(upload.id)
    end

    test "delete_upload/1 deletes the upload" do
      upload = upload_fixture()
      assert {:ok, %Upload{}} = Uploads.delete_upload(upload)
      assert_raise Ecto.NoResultsError, fn -> Uploads.get_upload!(upload.id) end
    end

    test "change_upload/1 returns a upload changeset" do
      upload = upload_fixture()
      assert %Ecto.Changeset{} = Uploads.change_upload(upload)
    end
  end
end
