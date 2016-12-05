defmodule PhotoUploader do
  use Azalea

  @mini_base_path Path.join(__DIR__, "../../upload/images/avatars")
  @mini_base_url "http://localhost:4000/images/avatars"

  @qiniu_scope "azalea"
  @remote_base_path "avatars"

  checker do
    type allow: ~w/jpg png gif/a
    size min: 10, max: 3000
  end

  handler :mini do
    name :mini
    system "convert", ~w/-gravity center -resize 64x64^ -extent 64x64/
    upload Azalea.Uploader.Local, base_path: @mini_base_path,
             base_url: @mini_base_url, kind: :mini
  end

  handler :remote do
    name :remote
    upload Azalea.Uploader.Qiniu, scope: @qiniu_scope,
             base_path: @remote_base_path, kind: :remote
  end

  def name(kind) do
    "#{100000..999999 |> Enum.random}#{System.os_time(:seconds)}_#{kind}"
    |> Base.url_encode64(padding: false)
    |> String.downcase
  end
end
