defmodule Core.Products do
  @moduledoc """
  The Products context.
  """
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Product

  def list_products do
    Repo.all(Product)
  end

  def get_product(id) do
    Repo.get(Product, id)
  end

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end
end
