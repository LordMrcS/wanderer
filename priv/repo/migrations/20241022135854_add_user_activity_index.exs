defmodule WandererApp.Repo.Migrations.AddUserActivityIndex do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create index(:user_activity_v1, [:entity_id, :event_type, :inserted_at], unique: true)
  end

  def down do
    drop_if_exists index(:user_activity_v1, [:entity_id, :event_type, :inserted_at])
  end
end
