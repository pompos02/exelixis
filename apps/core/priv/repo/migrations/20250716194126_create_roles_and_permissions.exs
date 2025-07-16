defmodule Core.Repo.Migrations.CreateRolesAndPermissions do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :tenant_id, references(:tenants, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:roles, [:tenant_id])
    create unique_index(:roles, [:tenant_id, :name])

    create table(:permissions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false # e.g., "orders:create", "inventory:view_stock"

      timestamps()
    end

    create unique_index(:permissions, [:name])
  end
end
