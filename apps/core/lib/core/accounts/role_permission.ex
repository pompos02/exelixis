defmodule Core.Accounts.RolePermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Accounts.{Role, Permission}

  @primary_key false
  @foreign_key_type :binary_id
  schema "roles_permissions" do
    belongs_to :role, Role, primary_key: true
    belongs_to :permission, Permission, primary_key: true
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