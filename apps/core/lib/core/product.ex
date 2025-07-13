defmodule Core.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "products" do
    field(:name, :string)
    field(:stock_level, :integer, default: 0)

    has_many(:orders, Core.Order)
    timestamps()
  end

  @doc """
    changeset for the producst
  """

  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :stock_level])
    |> validate_required([:name, :stock_level])
    |> unique_constraint(:name)
  end
end
