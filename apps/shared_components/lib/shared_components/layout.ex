defmodule SharedComponents.Layout do
  use Phoenix.Component

  # This component will render our shared sidebar.
  # It takes an `@current_url` assign to highlight the active application.
  def sidebar(assigns) do
    # Extract current app from URL
    current_app = extract_app_from_url(assigns[:current_url])
    available_plugins = get_available_plugins(assigns[:current_tenant])

    assigns =
      assigns
      |> assign(:current_app, current_app)
      |> assign(:available_plugins, available_plugins)

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
            <%= for plugin <- @available_plugins do %>
              <%=render_plugin_link(plugin, @current_app)%>
            <% end %>
          </nav>
        </div>

        <div class="mt-auto border-t p-4">
          <%= if @current_user do %>
            <div class="font-semibold"><%= @current_user.name %></div>
            <div class="text-xs text-muted-foreground"><%= @current_tenant && @current_tenant.name || "No Tenant" %></div>
            <div class="mt-2 flex flex-col gap-1 text-xs">
              <.link href="http://auth.exelixis.local:8000/users/settings" class="hover:underline">
                Settings
              </.link>
              <.link href="http://auth.exelixis.local:8000/users/log_out" method="delete" class="text-red-500 hover:underline">
                Log out
              </.link>
            </div>
          <% else %>
            <.link href="http://auth.exelixis.local:8000/users/log_in" class="text-sm font-semibold">
              Log in / Register
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # Helper function to extract app name from URL
  defp extract_app_from_url(url) when is_binary(url) do
    case URI.parse(url) do
      %{host: "inventory.exelixis.local"} -> "inventory"
      %{host: "orders.exelixis.local"} -> "orders"
      %{host: "auth.exelixis.local"} -> "auth"
      _ -> nil
    end
  end

  defp extract_app_from_url(_), do: nil

  defp get_available_plugins(%{plugins: plugins}) when is_list(plugins), do: plugins
  defp get_available_plugins(_), do: []

  defp render_plugin_link(%{name: "inventory"}, current_app) do
    assigns = %{current_app: current_app}

    ~H"""
    <.link
      href="http://inventory.exelixis.local:8000"
      class={[
        "px-3 py-2 rounded-md transition-colors flex items-center gap-2",
        if(@current_app == "inventory",
           do: "bg-primary text-primary-foreground font-semibold",
           else: "text-muted-foreground hover:bg-muted hover:text-foreground")
      ]}>
        Inventory
    </.link>
    """
  end

  defp render_plugin_link(%{name: "orders"}, current_app) do
    assigns = %{current_app: current_app}

    ~H"""
    <.link
      href="http://orders.exelixis.local:8000"
      class={[
        "px-3 py-2 rounded-md transition-colors flex items-center gap-2",
        if(@current_app == "orders",
           do: "bg-primary text-primary-foreground font-semibold",
           else: "text-muted-foreground hover:bg-muted hover:text-foreground")
      ]}>
        Orders
    </.link>
    """
  end

  # Fallback for unknown plugins
  defp render_plugin_link(_, _), do: nil
end
