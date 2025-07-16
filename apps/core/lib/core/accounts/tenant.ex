defmodule Core.Accounts.Tenant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Accounts.{User, TenantPlugin}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tenants" do
    field :name, :string

    # Associations
    has_many :users, User
    has_many :tenant_plugins, TenantPlugin
    has_many :plugins, through: [:tenant_plugins, :plugin]

    timestamps(type: :utc_datetime)
  end

  @doc """
  A tenant changeset for creating and updating tenants.
  """
  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> unique_constraint(:name)
  end
end