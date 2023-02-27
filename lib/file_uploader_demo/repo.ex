defmodule FileUploaderDemo.Repo do
  use Ecto.Repo,
    otp_app: :file_uploader_demo,
    adapter: Ecto.Adapters.Postgres
end
