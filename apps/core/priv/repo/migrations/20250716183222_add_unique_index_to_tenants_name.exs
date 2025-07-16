defmodule Core.Repo.Migrations.AddUniqueIndexToTenantsName do
  use Ecto.Migration

  def change do
    create unique_index(:tenants, [:name])
  end
end
