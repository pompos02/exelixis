defmodule Core.Accounts.Roles do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Accounts.Role

  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def add_permission_to_role(role, permission) do
    alias Core.Accounts.RolePermission
    
    %RolePermission{}
    |> RolePermission.changeset(%{role_id: role.id, permission_id: permission.id})
    |> Repo.insert()
    |> case do
      {:ok, _role_permission} -> {:ok, role}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
