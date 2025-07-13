defmodule InventoryWeb.ProductIndexLive do
  use InventoryWeb, :live_view

  alias Core.Products

  @impl true
  def mount(_params, _session, socket) do
    # fetching the products from the core application
    products = Products.list_products()
    # subing
    if connected?(socket) do
      for product <- products do
        Phoenix.PubSub.subscribe(Core.PubSub, "products:" <> product.id)
      end
    end

    {:ok,
     socket
     |> assign(:products, products)}
  end

  @impl true
  def handle_info({:product_updated, updated_product}, socket) do
    # Find and update the specific product in the list
    updated_products =
      Enum.map(socket.assigns.products, fn product ->
        if product.id == updated_product.id do
          updated_product
        else
          product
        end
      end)

    {:noreply, assign(socket, :products, updated_products)}
  end
end
