defmodule Core.Accounts.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Accounts.{Role, RolePermission}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "permissions" do
    field(:name, :string)

    # Associations
    has_many(:role_permissions, RolePermission)
    has_many(:roles, through: [:role_permissions, :role])

    timestamps(type: :utc_datetime)
  end

  @doc """
  A permission changeset for creating and updating permissions.
  """
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_permission_format(:name)
    |> unique_constraint(:name)
  end

  # Validate permission format like "orders:create", "inventory:read"
  defp validate_permission_format(changeset, field) do
    validate_format(changeset, field, ~r/^[a-z_]+:[a-z_]+$/,
      message: "must be in format 'resource:action' (e.g., 'orders:create')"
    )
  end
end

