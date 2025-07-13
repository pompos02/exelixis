defmodule OrdersWeb.OrderIndexLive do
  use OrdersWeb, :live_view

  alias Core.Orders
  alias Core.Repo

  @impl true
  def mount(_params, _session, socket) do
    # sub to the orders only when conntected

    # We must preload the :product association to display the product name
    orders = Orders.list_orders() |> Repo.preload(:product)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Core.PubSub, "orders")
    end

    {:ok,
     socket
     |> assign(:orders, orders)
     |> assign(:page_title, "All Orders")}
  end

  # Add this new function to handle the broadcast message
  @impl true
  def handle_info({:order_created, _order}, socket) do
    # Refresh the orders list when a new order is created
    orders = Orders.list_orders() |> Repo.preload(:product)
    {:noreply, assign(socket, :orders, orders)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      All Orders
      <:subtitle>A list of all orders that have been placed.</:subtitle>
    </.header>

    <div class="not-prose rounded-xl bg-slate-50 p-6">
      <ul class="divide-y divide-slate-100">
        <li :for={order <- @orders} class="flex items-center justify-between py-4">
          <div>
            <p class="text-sm font-semibold leading-6 text-slate-900">
              {order.customer_name}
            </p>
            <p class="mt-1 text-xs leading-5 text-slate-500">
              Product: {order.product.name}
            </p>
          </div>
          <p class="rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-slate-900 shadow-sm ring-1 ring-inset ring-slate-200">
            Quantity: {order.product_quantity}
          </p>
        </li>
      </ul>
    </div>
    """
  end
end
