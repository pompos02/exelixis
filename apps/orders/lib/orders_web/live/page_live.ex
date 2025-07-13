defmodule OrdersWeb.PageLive do
  use OrdersWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Orders Management Mr Stragi
      <:subtitle>Create new orders or view existing ones.</:subtitle>
    </.header>

    <div class="flex justify-center gap-4">
      <.link
        navigate={~p"/orders/new"}
        class="rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
      >
        Create New Order
      </.link>
      <.link
        navigate={~p"/orders"}
        class="rounded-md bg-white px-3.5 py-2.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
      >
        View All Orders
      </.link>
    </div>
    """
  end
end
