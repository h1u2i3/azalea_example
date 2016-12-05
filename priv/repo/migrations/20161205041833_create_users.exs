defmodule AzaleaExample.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :photo, :text

      timestamps
    end
  end
end
