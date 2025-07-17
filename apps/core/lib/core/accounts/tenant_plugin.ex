defmodule Core.Accounts.TenantPlugin do
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Accounts.{Tenant, Plugin}

  @primary_key false
  @foreign_key_type :binary_id
  schema "tenants_plugins" do
    belongs_to(:tenant, Tenant)
    belongs_to(:plugin, Plugin)
  end

  @doc """
  A tenant_plugin changeset for creating and updating tenant plugin associations.
  """
  def changeset(tenant_plugin, attrs) do
    tenant_plugin
    |> cast(attrs, [:tenant_id, :plugin_id])
    |> validate_required([:tenant_id, :plugin_id])
    |> foreign_key_constraint(:tenant_id)
    |> foreign_key_constraint(:plugin_id)
    |> unique_constraint([:tenant_id, :plugin_id])
  end
end

