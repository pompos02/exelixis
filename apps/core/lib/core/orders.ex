defmodule Core.Orders do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Order
  alias Core.Product
  alias Ecto.Multi
  import Ecto.Changeset

  def list_orders do
    Order
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_order(id) do
    Repo.get(Order, id)
  end

  @doc """
  Creates an order and decrements the associated product's stock level
  in a single database transaction.

  Returns `{:ok, %{order: order, product: product}}` on success.

  Returns `{:error, :insufficient_stock, changeset}` if there is not enough stock.

  Returns `{:error, failed_operation, failed_value, changes_so_far}` on other
  database errors.
  """
  def create_order(attrs \\ %{}) do
    # Start a new, empty transaction
    Multi.new()
    |> Multi.run(:product, fn _repo, _changes ->
      # 1. Fetch the product so we can check its stock
      case Repo.get(Product, attrs["product_id"]) do
        nil -> {:error, :product_not_found}
        product -> {:ok, product}
      end
    end)
    |> Multi.run(:order_changeset, fn _repo, %{product: product} ->
      # 2. Prepare the order changeset
      changeset = Order.changeset(%Order{}, attrs)
      quantity_in_order = get_field(changeset, :product_quantity)

      # 3. Check if there is enough stock
      if product.stock_level >= quantity_in_order do
        {:ok, changeset}
      else
        # If not enough stock, add an error and stop the transaction
        {:error, add_error(changeset, :product_id, "is out of stock")}
      end
    end)
    |> Multi.insert(:order, fn %{order_changeset: changeset} ->
      # 4. If stock is sufficient, insert the order
      changeset
    end)
    |> Multi.update(:product_update, fn %{product: product, order: order} ->
      # 5. Decrement the product's stock level
      Product.changeset(product, %{
        stock_level: product.stock_level - order.product_quantity
      })
    end)
    |> Repo.transaction()
    |> handle_order_creation_result()
  end

  defp handle_order_creation_result({:ok, %{order: order, product_update: product}}) do
    # 6. If the transaction was successful, broadcast notifications!
    Phoenix.PubSub.broadcast!(
      Core.PubSub,
      Core.PubSubTopics.orders_list(),
      {:order_created, order}
    )

    Phoenix.PubSub.broadcast!(
      Core.PubSub,
      Core.PubSubTopics.product(product.id),
      {:product_updated, product}
    )

    {:ok, order}
  end

  defp handle_order_creation_result({:error, :order_changeset, changeset, _changes}) do
    # This happens if there wasn't enough stock
    {:error, changeset}
  end

  defp handle_order_creation_result({:error, _failed_operation, failed_value, _changes}) do
    # Handle other potential errors, like the product not being found
    {:error, failed_value}
  end
end
