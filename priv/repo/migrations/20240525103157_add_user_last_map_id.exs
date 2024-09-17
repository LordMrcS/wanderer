defmodule WandererApp.Repo.Migrations.AddUserLastMapId do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:user_v1) do
      add :last_map_id, :uuid
    end
  end

  def down do
    alter table(:user_v1) do
      remove :last_map_id
    end
  end
end
