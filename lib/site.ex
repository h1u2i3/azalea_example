defmodule Site do
  use Plug.Router

  plug Plug.Static,
    at: "/",
    from: Path.join(__DIR__, "../upload"),
    only: ~w(images robots.txt)
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Site.View.upload_html("upload"))
  end

  get "/ecto" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Site.View.upload_html("ecto"))
  end

  get "/ecto_multi" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Site.View.multi_upload_html("ecto"))
  end

  post "/ecto" do
    changeset = Ecto.Changeset.cast(Site.User.empty,
                                    conn.params["user"], [:photo])
    result =
      changeset
      |> AzaleaExample.Repo.insert!
      |> Macro.to_string

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Site.View.upload_response_html(result))
  end

  post "/upload" do
    response =
      PhotoUploader.handle(conn.params["user"]["photo"])
      |> Macro.to_string

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, Site.View.upload_response_html(response))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

end

defmodule Site.User do
  use Ecto.Schema

  schema "users" do
    field :photo, PhotoUploader

    timestamps
  end

  def empty do
    %__MODULE__{}
  end
end

defmodule Site.View do
  def upload_html(target) do
    """
    <form action="/#{target}" method="post" enctype="multipart/form-data">
      <input id="user_photo" name="user[photo]" type="file"><br/>
      <input type="submit" value="Submit">
    </form>
    """
  end

  def multi_upload_html(target) do
    """
    <form action="/#{target}" method="post" enctype="multipart/form-data">
      <input id="user_photo" name="user[photo][]" type="file"><br/>
      <input id="user_photo" name="user[photo][]" type="file"><br/>
      <input type="submit" value="Submit">
    </form>
    """
  end

  def upload_response_html(response) do
    """
    <p>Upload Success</p>
    <p>#{response}</p>
    """
  end
end
