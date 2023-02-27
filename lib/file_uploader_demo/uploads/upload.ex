defmodule FileUploaderDemo.Uploads.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do
    field :filename, :string

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:filename])
    |> validate_required([:filename])
  end
end
