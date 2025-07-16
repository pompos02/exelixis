defmodule Core.Repo.Migrations.CreatePlugins do
  use Ecto.Migration

  def change do
    create table(:plugins, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      timestamps()
    end
    
    create unique_index(:plugins, [:name])

  end
end
