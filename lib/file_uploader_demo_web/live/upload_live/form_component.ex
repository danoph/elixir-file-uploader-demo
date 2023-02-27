defmodule FileUploaderDemoWeb.UploadLive.FormComponent do
  use FileUploaderDemoWeb, :live_component

  alias FileUploaderDemo.Uploads

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage upload records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="upload-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.live_file_input upload={@uploads.file} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Upload</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{upload: upload} = assigns, socket) do
    changeset = Uploads.change_upload(upload)

    {:ok,
     socket
     |> assign(assigns)
     |> allow_upload(:file, accept: :any, max_file_size: 800_000_000_000, external: &presign_upload/2)
     |> assign_form(changeset)}
  end

  defp presign_upload(entry, socket) do
    uploads = socket.assigns.uploads
    bucket = "danoph-file-uploader-demo"
    key = "elixir/#{entry.client_name}"

    config = %{
      region: "us-east-1",
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      FileUploaderDemoWeb.SimpleS3Upload.sign_form_upload(config, bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads[entry.upload_config].max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{
      uploader: "S3",
      key: key,
      url: "https://#{bucket}.s3.amazonaws.com",
      #https://danoph-file-uploader-demo.s3.amazonaws.com/Screenshot+2023-02-17+at+2.06.32+PM.png
      fields: fields
    }

    {:ok, meta, socket}
  end

  @impl true
  def handle_event("validate", %{"upload" => upload_params}, socket) do
    changeset =
      socket.assigns.upload
      |> Uploads.change_upload(upload_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"upload" => upload_params}, socket) do
    save_upload(socket, socket.assigns.action, upload_params)
  end

  def handle_event("save", _params, socket) do
    socket
    |> consume_uploaded_entries(:file, fn (thing, entry) ->
      IO.inspect thing, label: "thing"
      IO.inspect entry, label: "entry"
      {:ok, "/somewhere"} end)

    {:noreply, socket}
  end

  defp save_upload(socket, :edit, upload_params) do
    case Uploads.update_upload(socket.assigns.upload, upload_params) do
      {:ok, upload} ->
        notify_parent({:saved, upload})

        {:noreply,
         socket
         |> put_flash(:info, "Upload updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_upload(socket, :new, upload_params) do
    case Uploads.create_upload(upload_params) do
      {:ok, upload} ->
        notify_parent({:saved, upload})

        {:noreply,
         socket
         |> put_flash(:info, "Upload created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
