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

    # |> validate_customer_name_word_count()
  end

  defp validate_customer_name_word_count(changeset) do
    # Get the value of :customer_name from the changeset (either current value or a change)
    case get_field(changeset, :customer_name) do
      nil ->
        # No customer name, assume it's handled by validate_required
        changeset

      customer_name ->
        # Split the string by spaces and count the resulting elements
        word_count = String.split(customer_name, " ", trim: true) |> Enum.count()

        if word_count > 4 do
          changeset
        else
          add_error(changeset, :customer_name, "must be longer than 4 words")
        end
    end
  end
end
