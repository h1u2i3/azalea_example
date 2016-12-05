# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :azalea_example,
  ecto_repos: [AzaleaExample.Repo]

config :azalea, Azalea.Uploader.Qiniu,
  access_key: System.get_env("QINIU_AK"),
  secret_key: System.get_env("QINIU_SK")

config :azalea_example, AzaleaExample.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "azalea_example_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10

