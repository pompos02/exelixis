defmodule Core.Accounts.Permissions do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Accounts.Permission

  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end
end
