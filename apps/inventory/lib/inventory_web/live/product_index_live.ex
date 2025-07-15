defmodule InventoryWeb.ProductIndexLive do
  use InventoryWeb, :live_view

  alias Core.Products
  alias Core.PubSubTopics

  @impl true
  def render(assigns) do
    ~H"""
    <.header>Product Inventroy Mr Stragi</.header>

    <div class="not-prose rounded-xl bg-slate-50 p-6">
      <ul class="divide-y divide-slate-100">
        <%= for product <- @products do %>
          <li class="flex items-center justify-between py-4">
            <div class="flex items-center gap-x-3">
              <p class="text-sm font-semibold leading-6 text-slate-900">{product.name}</p>
            </div>
            <p class="rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-slate-900 shadow-sm ring-1 ring-inset ring-slate-200">
              Stock: {product.stock_level}
            </p>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # fetching the products from the core application
    products = Products.list_products()
    # subing
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Core.PubSub, PubSubTopics.products_list())

      for product <- products do
        Phoenix.PubSub.subscribe(Core.PubSub, PubSubTopics.product(product.id))
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

  @impl true
  def handle_info({:product_added, new_product}, socket) do
    # Handle new products being added
    Phoenix.PubSub.subscribe(Core.PubSub, PubSubTopics.product(new_product.id))
    updated_products = [new_product | socket.assigns.products]
    {:noreply, assign(socket, :products, updated_products)}
  end

  @impl true
  def handle_info({:product_removed, product_id}, socket) do
    # Handle products being removed
    Phoenix.PubSub.unsubscribe(Core.PubSub, PubSubTopics.product(product_id))
    updated_products = Enum.reject(socket.assigns.products, &(&1.id == product_id))
    {:noreply, assign(socket, :products, updated_products)}
  end
end
