defmodule WandererApp.Repo.Migrations.UserCharacters do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:user_v1, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text
      add :hash, :text
    end

    create table(:character_v1, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :eve_id, :text, null: false
      add :name, :text, null: false
      add :online, :boolean, default: false
      add :scopes, :text
      add :character_owner_hash, :text
      add :access_token, :text
      add :refresh_token, :text
      add :token_type, :text
      add :expires_at, :bigint
      add :location, :text
      add :ship, :bigint

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :user_id,
          references(:user_v1,
            column: :id,
            name: "character_v1_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:character_v1, "character_v1_user_id_fkey")

    drop table(:character_v1)

    drop table(:user_v1)
  end
end
