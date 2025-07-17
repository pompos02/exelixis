defmodule SharedComponents.Layout do
  use Phoenix.Component

  # This component will render our shared sidebar.
  # It takes an `@current_path` assign to highlight the active link.
  def sidebar(assigns) do
    ~H"""
    <nav class="flex flex-col p-4 bg-slate-100 border-r border-slate-200 space-y-2">
      <h2 class="font-bold text-lg mb-4">EUKO PSIXOPATHIS </h2>

      <.link
        href="http://inventory.localhost:8000/"
        class={"text-sm font-semibold leading-6 rounded-md p-2 #{if @current_path == "/", do: "bg-slate-200 text-slate-900", else: "text-slate-700 hover:bg-slate-200"}"}
      >
        Inventory
      </.link>

      <.link
        href="http://orders.localhost:8000"
        class={"text-sm font-semibold leading-6 rounded-md p-2 #{if @current_path == "/", do: "bg-slate-200 text-slate-900", else: "text-slate-700 hover:bg-slate-200"}"}
      >
        Orders
      </.link>

      <.link
        href="http://auth.localhost:8000"
        class={"text-sm font-semibold leading-6 rounded-md p-2 #{if @current_path == "/", do: "bg-slate-200 text-slate-900", else: "text-slate-700 hover:bg-slate-200"}"}
      >
       Login
      </.link>

    </nav>
    """
  end
end
