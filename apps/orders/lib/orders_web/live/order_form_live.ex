defmodule OrdersWeb.OrderFormLive do
  use OrdersWeb, :live_view
  alias Core.Orders
  alias Core.Products
  alias Core.Order

  @impl true
  def mount(_params, _session, socket) do
    products = Products.list_products()
    changeset = Order.changeset(%Order{}, %{})

    {:ok,
     socket
     |> assign(:products, products)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset =
      %Order{}
      |> Order.changeset(order_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"order" => order_params}, socket) do
    case Orders.create_order(order_params) do
      {:ok, order} ->
        # i will brodcust the order to its subs
        Phoenix.PubSub.broadcast(Core.PubSub, "orders", {:order_created, order})

        {:noreply,
         socket
         |> put_flash(:info, "Order created successfully")
         |> push_navigate(to: ~p"/orders")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Create a New Order
      <:subtitle>Select a product and enter the customer details.</:subtitle>
    </.header>
    <div>
      <.form for={@form} id="order-form" phx-change="validate" phx-submit="save" class="space-y-4">
        <.input field={@form[:customer_name]} type="text" label="Customer Name" required />
        <.input field={@form[:product_quantity]} type="number" label="Product Quantity" required />
        <.input
          type="select"
          field={@form[:product_id]}
          label="Product"
          prompt="Please select a product"
          options={Enum.map(@products, &{&1.name, &1.id})}
          required
        />
        <div class="mt-4">
          <.button phx-disable-with="Saving...">Create Order</.button>
        </div>
      </.form>
    </div>
    """
  end
end
