defmodule Core.Repo.Migrations.CreateJoinTables do
  use Ecto.Migration

  def change do
    create table(:tenants_plugins, primary_key: false) do
      add :tenant_id, references(:tenants, on_delete: :delete_all, type: :binary_id)
      add :plugin_id, references(:plugins, on_delete: :delete_all, type: :binary_id)
    end

    create table(:users_roles, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :role_id, references(:roles, on_delete: :delete_all, type: :binary_id)
    end

    create table(:roles_permissions, primary_key: false) do
      add :role_id, references(:roles, on_delete: :delete_all, type: :binary_id)
      add :permission_id, references(:permissions, on_delete: :delete_all, type: :binary_id)
    end
  end
end
