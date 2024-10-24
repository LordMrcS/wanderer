defmodule WandererApp.Repo.Migrations.AddConnectionCustomInfo do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:map_chain_v1) do
      add :custom_info, :text
    end
  end

  def down do
    alter table(:map_chain_v1) do
      remove :custom_info
    end
  end
end
