defmodule FileUploaderDemo.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :filename, :string

      timestamps()
    end
  end
end
