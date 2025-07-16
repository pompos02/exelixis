defmodule Core.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Accounts.{Tenant, UserRole, Permission, RolePermission}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "roles" do
    field(:name, :string)

    # Associations
    belongs_to(:tenant, Tenant)
    has_many(:user_roles, UserRole)
    has_many(:users, through: [:user_roles, :user])
    has_many(:role_permissions, RolePermission)
    has_many(:permissions, through: [:role_permissions, :permission])

    timestamps(type: :utc_datetime)
  end

  @doc """
  A role changeset for creating and updating roles.
  """
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> unique_constraint(:name)
  end
end

