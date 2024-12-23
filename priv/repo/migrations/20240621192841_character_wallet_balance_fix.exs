defmodule WandererApp.Repo.Migrations.CharacterWalletBalanceFix do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    rename table(:character_v1), :wallet_ballance, to: :wallet_balance

    alter table(:character_v1) do
      modify :wallet_balance, :text
    end
  end

  def down do
    alter table(:character_v1) do
      modify :wallet_ballance, :text
    end

    rename table(:character_v1), :wallet_balance, to: :wallet_ballance
  end
end
