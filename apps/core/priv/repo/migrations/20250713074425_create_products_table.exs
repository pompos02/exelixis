defmodule Core.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)
      add(:stock_level, :integer, default: 0, null: false)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:products, [:name]))
  end
end
