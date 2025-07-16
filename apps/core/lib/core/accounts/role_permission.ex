defmodule Core.Accounts.RolePermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Accounts.{Role, Permission}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "role_permissions" do
    belongs_to :role, Role
    belongs_to :permission, Permission

    timestamps(type: :utc_datetime)
  end

  @doc """
  A role_permission changeset for creating and updating role permission associations.
  """
  def changeset(role_permission, attrs) do
    role_permission
    |> cast(attrs, [:role_id, :permission_id])
    |> validate_required([:role_id, :permission_id])
    |> foreign_key_constraint(:role_id)
    |> foreign_key_constraint(:permission_id)
    |> unique_constraint([:role_id, :permission_id])
  end
end