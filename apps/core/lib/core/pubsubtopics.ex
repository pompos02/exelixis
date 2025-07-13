defmodule Core.PubSubTopics do
  @doc "Topic for general product list updates (additions, deletions)"
  def products_list, do: "inventory:products:list"

  @doc "Topic for specific product updates (stock changes, etc.)"
  def product(product_id), do: "inventory:product:#{product_id}"

  @doc "Topic for general order list updates"
  def orders_list, do: "orders:list"

  @doc "Topic for orders affecting a specific product"
  def orders_for_product(product_id), do: "orders:product:#{product_id}"
end
