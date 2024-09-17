defmodule WandererApp.Repo.Migrations.AddUniqAclMemberId do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create unique_index(
             :access_list_members_v1,
             [:access_list_id, :eve_character_id, :eve_corporation_id, :eve_alliance_id],
             name: "access_list_members_v1_uniq_acl_member_id_index"
           )
  end

  def down do
    drop_if_exists unique_index(
                     :access_list_members_v1,
                     [:access_list_id, :eve_character_id, :eve_corporation_id, :eve_alliance_id],
                     name: "access_list_members_v1_uniq_acl_member_id_index"
                   )
  end
end
