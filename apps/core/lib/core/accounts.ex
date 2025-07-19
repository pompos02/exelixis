defmodule Core.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Accounts.{User, UserToken, Tenant, UserRole}

  @doc """
  Function the returns if a specific tenant has a specific plugin true/false
  """
  def tenant_has_plugin?(tenant, plugin_name) do
    tenant
    |> Repo.preload(:plugins)
    |> Map.get(:plugins, [])
    |> Enum.any?(fn plugin -> plugin.name == plugin_name end)
  end

  @doc """
  Function that checks if a specific user has access to the plugin based on tenant
  """
  def user_has_plugin?(user, plugin_name) do
    case(get_tenant_by_user(user)) do
      nil -> false
      tenant -> tenant_has_plugin?(tenant, plugin_name)
    end
  end

  @doc """
  cheks if the user has a permission based on his role
  """
  def user_has_permission?(user, permission_name) do
    user
    |> Repo.preload(roles: :permissions)
    |> Map.get(:roles, [])
    |> Enum.flat_map(fn role -> role.permissions end)
    |> Enum.any?(fn permission -> permission.name == permission_name end)
  end

  @doc """
  checks whether a user can acess the inventory
  """
  def user_can_access_inventory?(user) do
    user_has_plugin?(user, "inventory")
  end

  @doc """
  chjecks if a user has acess to orders
  """
  def user_can_access_orders?(user) do
    user_has_plugin?(user, "orders")
  end

  def assign_role_to_user(user, role) do
    case Repo.get_by(UserRole, user_id: user.id, role_id: role.id) do
      nil ->
        %UserRole{}
        |> UserRole.changeset(%{user_id: user.id, role_id: role.id})
        |> Repo.insert()
        |> case do
          {:ok, _user_role} -> {:ok, user}
          error -> error
        end

      _existing ->
        {:ok, user}
    end
  end

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_name(name) when is_binary(name) do
    Repo.get_by(User, name: name)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a user by name and password.

  ## Examples

      iex> get_user_by_name_and_password("testuser", "correct_password")
      %User{}

      iex> get_user_by_name_and_password("testuser", "invalid_password")
      nil

  """
  def get_user_by_name_and_password(name, password)
      when is_binary(name) and is_binary(password) do
    user = Repo.get_by(User, name: name)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## Tenant management

  @doc """
  Returns the list of tenants.

  ## Examples

      iex> list_tenants()
      [%Tenant{}, ...]

  """
  def list_tenants do
    Repo.all(Tenant)
  end

  @doc """
  Gets a single tenant.

  Raises `Ecto.NoResultsError` if the Tenant does not exist.

  ## Examples

      iex> get_tenant!(123)
      %Tenant{}

      iex> get_tenant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tenant!(id), do: Repo.get!(Tenant, id)

  @doc """
  Creates a tenant.

  ## Examples

      iex> create_tenant(%{name: "Test Tenant"})
      {:ok, %Tenant{}}

      iex> create_tenant(%{name: ""})
      {:error, %Ecto.Changeset{}}

  """
  def create_tenant(attrs \\ %{}) do
    %Tenant{}
    |> Tenant.changeset(attrs)
    |> Repo.insert()
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs,
      hash_password: false,
      validate_email: false,
      validate_name: false
    )
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  @doc """
  Gets the tenant for the given user.
  """
  def get_tenant_by_user(user) when is_nil(user), do: nil
  def get_tenant_by_user(%User{tenant_id: tenant_id}) when is_nil(tenant_id), do: nil

  def get_tenant_by_user(%User{tenant_id: tenant_id}) do
    Repo.get(Tenant, tenant_id)
  end
end
