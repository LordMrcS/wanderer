defmodule WandererApp.Repo.Migrations.AddAuditByCharacterId do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:user_activity_v1) do
      add :character_id,
          references(:character_v1,
            column: :id,
            name: "user_activity_v1_character_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:user_activity_v1, "user_activity_v1_character_id_fkey")

    alter table(:user_activity_v1) do
      remove :character_id
    end
  end
end
