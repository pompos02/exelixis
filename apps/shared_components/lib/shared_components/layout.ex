defmodule SharedComponents.Layout do
  use Phoenix.Component

  # This component will render our shared sidebar.
  # It takes an `@current_path` assign to highlight the active link.
  def sidebar(assigns) do
    ~H"""
    <div class="h-full border-r border-border bg-muted/40">
      <div class="flex h-full max-h-screen flex-col">
        <div class="flex h-14 items-center border-b px-4 lg:h-[60px] lg:px-6">
          <p class="flex items-center gap-2 font-semibold">
            <span class="text-xl">EUKO PSIXOPATHIS</span>
          </p>
        </div>

        <div class="flex-1">
          <nav class="grid items-start gap-2 p-2 text-sm font-medium lg:px-4">
            <span class="px-2 py-2 text-xs font-semibold text-muted-foreground">Plugins</span>
            <.link href="http://inventory.localhost:8000" class="..." >
              Inventory
            </.link>
            <.link href="http://orders.localhost:8000" class="..." >
              Orders
            </.link>
          </nav>
        </div>

        <div class="mt-auto border-t p-4">
          <%= if @current_user do %>
            <div class="font-semibold"><%= @current_user.name %></div>
            <div class="text-xs text-muted-foreground"><%= @current_user.email %></div>
            <div class="mt-2 flex flex-col gap-1 text-xs">
              <.link href="http://auth.localhost:8000/users/settings" class="hover:underline">
                Settings
              </.link>
              <.link href="http://auth.localhost:8000/users/log_out" method="delete" class="text-red-500 hover:underline">
                Log out
              </.link>
            </div>
          <% else %>
            <.link href="http://auth.localhost:8000/users/log_in" class="text-sm font-semibold">
              Log in / Register
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
