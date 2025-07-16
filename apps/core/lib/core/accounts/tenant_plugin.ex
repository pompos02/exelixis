defmodule Core.Accounts.TenantPlugin do
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Accounts.{Tenant, Plugin}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tenant_plugins" do
    belongs_to :tenant, Tenant
    belongs_to :plugin, Plugin

    timestamps(type: :utc_datetime)
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