defmodule Core.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Product

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field(:customer_name, :string)
    field(:product_quantity, :integer)

    # Defines the Elixir-level relationship to a single product
    belongs_to(:product, Product)

    timestamps()
  end

  @doc """
  Builds a changeset for an order.
  """
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:customer_name, :product_quantity, :product_id])
    |> validate_required([:customer_name, :product_quantity, :product_id])
    |> validate_number(:product_quantity, greater_than: 0, message: "Μεγαλος Ροζ Πάνθηρας")
    |> foreign_key_constraint(:product_id)
  end
end
