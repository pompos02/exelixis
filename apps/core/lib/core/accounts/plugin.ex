defmodule Core.Accounts.Plugin do
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Accounts.{Tenant, TenantPlugin}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plugins" do
    field :name, :string
    field :description, :string

    # Associations
    has_many :tenant_plugins, TenantPlugin
    has_many :tenants, through: [:tenant_plugins, :tenant]

    timestamps(type: :utc_datetime)
  end

  @doc """
  A plugin changeset for creating and updating plugins.
  """
  def changeset(plugin, attrs) do
    plugin
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> unique_constraint(:name)
  end
end