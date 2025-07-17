defmodule Core.Accounts.Tenants do
  @doc """
  Returns a list with the available tenansts plugins
  """
  def list_allowed_plugin_names(tenant) do
    tenant
    |> Core.Repo.preload(:plugins)
    |> Map.get(:plugins, [])
    |> Enum.map(& &1.name)
  end
end
