defmodule Core.Repo.Migrations.AddPrimaryKeyToUsersRoles do
  use Ecto.Migration

  def change do
    alter table(:users_roles) do
      add :id, :binary_id, primary_key: true
      add :inserted_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
    end
  end
end
