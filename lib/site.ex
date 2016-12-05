defmodule Site do
  use Plug.Router
  require IEx

  plug Plug.Static,
    at: "/",
    from: Path.join(__DIR__, "../upload"), only: ~w(images robots.txt)
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug :match
  plug :dispatch

  get "/" do
    conn |> send_html(Site.View.index_html)
  end

  get "/ecto" do
    conn |> send_html(Site.View.upload_html("ecto"))
  end

  get "/ecto_multi" do
    conn |> send_html(Site.View.multi_upload_html("ecto"))
  end

  post "/ecto" do
    changeset = Site.User.changeset(Site.User.empty,
                                    conn.params["user"] || %{})
    result =
      changeset |> AzaleaExample.Repo.insert

    result =
      case result do
        {:error, changeset} -> Macro.to_string(changeset.errors)
        _ -> Macro.to_string(result)
      end

    conn |> send_resp(200, Site.View.upload_response_html(result))
  end

  get "/upload" do
    conn |> send_html(Site.View.upload_html("upload"))
  end

  post "/upload" do
    response =
      PhotoUploader.handle(conn.params["user"]["photo"])
      |> Macro.to_string

    conn |> send_html(Site.View.upload_response_html(response))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp send_html(conn, html) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end
end

defmodule Site.User do
  use Ecto.Schema
  import Ecto.Changeset
  import PhotoUploader, only: [validate_upload: 2]

  schema "users" do
    field :photo, PhotoUploader

    timestamps
  end

  def empty do
    %__MODULE__{}
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:photo])
    |> validate_required([:photo])
    |> validate_upload(:photo)
  end
end

defmodule Site.View do
  def index_html do
    """
    <h1>Azalea Example</h1>
    <ul>
      <li><a href="/upload">Check with the normal upload</a></li>
      <li><a href="/ecto">Upload single file with Ecto</a></li>
      <li><a href="/ecto_multi">Upload multi-files with Ecto</a></li>
    </ul>
    """
  end

  def upload_html(target) do
    """
    <form action="/#{target}" method="post" enctype="multipart/form-data">
      <ul>
        <li><input id="user_photo" name="user[photo]" type="file"></li>
        <li><input type="submit" value="Submit"></li>
      </ul>
    </form>
    """
  end

  def multi_upload_html(target) do
    """
    <form action="/#{target}" method="post" enctype="multipart/form-data">
      <ul>
        <li><input id="user_photo" name="user[photo][]" type="file"></li>
        <li><input id="user_photo" name="user[photo][]" type="file"></li>
        <li><input type="submit" value="Submit"></li>
      </ul>
    </form>
    """
  end

  def upload_response_html(response) do
    """
    <p>Upload Result</p>
    <p>#{response}</p>
    """
  end
end
