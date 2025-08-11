# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Core.Repo.insert!(%Core.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Core.Repo
alias Core.{Product, Order}
alias Core.Accounts.{Tenant, User, Role, Permission, Plugin, UserToken}
alias Core.Accounts.{TenantPlugin, UserRole, RolePermission}

IO.puts("<1 Starting database seeding...")

# Helper function for safe insertion
get_or_create = fn schema, attrs, get_by_field ->
  case Repo.get_by(schema, get_by_field) do
    nil ->
      IO.puts("Creating #{schema} with #{inspect(get_by_field)}")
      struct(schema)
      |> schema.changeset(attrs)
      |> Repo.insert!()
    existing ->
      IO.puts("Found existing #{schema} with #{inspect(get_by_field)}")
      existing
  end
end

# =============================================================================
# LEVEL 1: Independent Tables (No foreign key dependencies)
# =============================================================================

IO.puts("\n=? Seeding Level 1: Independent Tables")

# Products
product1 = get_or_create.(Product, %{
  name: "Laptop",
  stock_level: 50
}, name: "Laptop")

product2 = get_or_create.(Product, %{
  name: "Mouse",
  stock_level: 100
}, name: "Mouse")

product3 = get_or_create.(Product, %{
  name: "Keyboard",
  stock_level: 75
}, name: "Keyboard")

# Tenants
tenant1 = get_or_create.(Tenant, %{
  name: "Tenant 1"
}, name: "Tenant 1")

tenant2 = get_or_create.(Tenant, %{
  name: "Tenant 2"
}, name: "Tenant 2")

# Plugins
plugin1 = get_or_create.(Plugin, %{
  name: "inventory"
}, name: "inventory")

plugin2 = get_or_create.(Plugin, %{
  name: "orders"
}, name: "orders")

# Permissions
perm1 = get_or_create.(Permission, %{
 name: "orders:create"
}, name: "orders:create")

perm2 = get_or_create.(Permission, %{
  name: "orders:view_all"
}, name: "orders:view_all")

perm3 = get_or_create.(Permission, %{
  name: "inventory:view_all"
}, name: "inventory:view_all")

# =============================================================================
# LEVEL 2: First-Level Dependent Tables
# =============================================================================

IO.puts("\n=e Seeding Level 2: First-Level Dependent Tables")

# Users (depends on tenants)
user1 = get_or_create.(User, %{
  name: "John Admin",
  email: "john@acmecorp.com",
  hashed_password: Bcrypt.hash_pwd_salt("password"),
  tenant_id: tenant1.id
}, email: "john@acmecorp.com")

user2 = get_or_create.(User, %{
  name: "Jane Viewer",
  email: "jane@acmecorp.com", 
  hashed_password: Bcrypt.hash_pwd_salt("password"),
  tenant_id: tenant1.id
}, email: "jane@acmecorp.com")

user3 = get_or_create.(User, %{
  name: "Bob Viewer",
  email: "bob@techstart.com",
  hashed_password: Bcrypt.hash_pwd_salt("password"),
  tenant_id: tenant2.id
}, email: "bob@techstart.com")

user4 = get_or_create.(User, %{
  name: "Iasonas Admin",
  email: "iasonas@euko.com",
  hashed_password: Bcrypt.hash_pwd_salt("password"),
  tenant_id: tenant2.id
}, email: "iasonas@euko.com")

# Roles (depends on tenants)
role1 = get_or_create.(Role, %{
  name: "admin",
  tenant_id: tenant1.id
}, [tenant_id: tenant1.id, name: "admin"])

role2 = get_or_create.(Role, %{
  name: "viewer",
  tenant_id: tenant1.id
}, [tenant_id: tenant1.id, name: "viewer"])

role3 = get_or_create.(Role, %{
  name: "viewer",
  tenant_id: tenant2.id
}, [tenant_id: tenant2.id, name: "viewer"])

role4 = get_or_create.(Role, %{
  name: "admin",
  tenant_id: tenant2.id
}, [tenant_id: tenant2.id, name: "admin"])

# Orders (depends on products)

# We shouldld create orders form here

# order1 = get_or_create(Order, %{
#   customer_name: "Alice Smith",
#   product_quantity: 2,
#   product_id: product1.id
# }, customer_name: "Alice Smith")
#
# order2 = get_or_create(Order, %{
#   customer_name: "Charlie Brown",
#   product_quantity: 5,
#   product_id: product2.id
# }, customer_name: "Charlie Brown")
#
# order3 = get_or_create(Order, %{
#   customer_name: "David Wilson", 
#   product_quantity: 1,
#   product_id: product3.id
# }, customer_name: "David Wilson")

# =============================================================================
# LEVEL 3: Second-Level Dependent Tables
# =============================================================================

IO.puts("\n= Seeding Level 3: Second-Level Dependent Tables")


# =============================================================================
# LEVEL 4: Join Tables (Many-to-many relationships)
# =============================================================================

IO.puts("\n= Seeding Level 4: Join Tables")

# Tenants Plugins (depends on tenants + plugins)
case Repo.get_by(TenantPlugin, tenant_id: tenant1.id, plugin_id: plugin1.id) do
  nil ->
    IO.puts("Linking tenant #{tenant1.name} to plugin #{plugin1.name}")
    %TenantPlugin{}
    |> TenantPlugin.changeset(%{tenant_id: tenant1.id, plugin_id: plugin1.id})
    |> Repo.insert!()
  existing ->
    IO.puts("Found existing tenant-plugin link: #{tenant1.name} <-> #{plugin1.name}")
    existing
end

case Repo.get_by(TenantPlugin, tenant_id: tenant1.id, plugin_id: plugin2.id) do
  nil ->
    IO.puts("Linking tenant #{tenant1.name} to plugin #{plugin2.name}")
    %TenantPlugin{}
    |> TenantPlugin.changeset(%{tenant_id: tenant1.id, plugin_id: plugin2.id})
    |> Repo.insert!()
  existing ->
    IO.puts("Found existing tenant-plugin link: #{tenant1.name} <-> #{plugin2.name}")
    existing
end

case Repo.get_by(TenantPlugin, tenant_id: tenant2.id, plugin_id: plugin1.id) do
  nil ->
    IO.puts("Linking tenant #{tenant2.name} to plugin #{plugin1.name}")
    %TenantPlugin{}
    |> TenantPlugin.changeset(%{tenant_id: tenant2.id, plugin_id: plugin1.id})
    |> Repo.insert!()
  existing ->
    IO.puts("Found existing tenant-plugin link: #{tenant2.name} <-> #{plugin1.name}")
    existing
end

# Users Roles (depends on users + roles)
case Repo.get_by(UserRole, user_id: user1.id, role_id: role1.id) do
  nil ->
    IO.puts("Assigning role #{role1.name} to user #{user1.name}")
    %UserRole{}
    |> UserRole.changeset(%{user_id: user1.id, role_id: role1.id})
    |> Repo.insert!()
  existing ->
    IO.puts("Found existing user-role assignment: #{user1.name} <-> #{role1.name}")
    existing
end

case Repo.get_by(UserRole, user_id: user2.id, role_id: role2.id) do
  nil ->
    IO.puts("Assigning role #{role2.name} to user #{user2.name}")
    %UserRole{}
    |> UserRole.changeset(%{user_id: user2.id, role_id: role2.id})
    |> Repo.insert!()
  existing ->
    IO.puts("Found existing user-role assignment: #{user2.name} <-> #{role2.name}")
    existing
end

# role4 is admin for tenant2
case Repo.get_by(UserRole, user_id: user3.id, role_id: role4.id) do
  nil ->
    IO.puts("Assigning role #{role4.name} to user #{user3.name}")
    %UserRole{}
    |> UserRole.changeset(%{user_id: user3.id, role_id: role4.id})
    |> Repo.insert!()
  existing ->
    IO.puts("Found existing user-role assignment: #{user3.name} <-> #{role4.name}")
    existing
end


case Repo.get_by(UserRole, user_id: user4.id, role_id: role4.id) do
  nil ->
    IO.puts("Assigning role #{role4.name} to user #{user4.name}")
    %UserRole{}
    |> UserRole.changeset(%{user_id: user4.id, role_id: role4.id})
    |> Repo.insert!()
  existing ->
    IO.puts("Found existing user-role assignment: #{user4.name} <-> #{role4.name}")
    existing
end
# Roles Permissions (depends on roles + permissions)
# Admin role gets all permissions for tentant1 and tenant2
admin_permissions = [perm1, perm2, perm3]
for perm <- admin_permissions do
  case Repo.get_by(RolePermission, role_id: role1.id, permission_id: perm.id) do
    nil ->
      IO.puts("Granting permission #{perm.name} to role #{role1.name}")
      %RolePermission{}
      |> RolePermission.changeset(%{role_id: role1.id, permission_id: perm.id})
      |> Repo.insert!()
    existing ->
      IO.puts("Found existing role-permission: #{role1.name} <-> #{perm.name}")
      existing
  end
end

# Admin role gets all permissions for tentant2
for perm <- admin_permissions do
  case Repo.get_by(RolePermission, role_id: role4.id, permission_id: perm.id) do
    nil ->
      IO.puts("Granting permission #{perm.name} to role #{role4.name}")
      %RolePermission{}
      |> RolePermission.changeset(%{role_id: role4.id, permission_id: perm.id})
      |> Repo.insert!()
    existing ->
      IO.puts("Found existing role-permission: #{role4.name} <-> #{perm.name}")
      existing
  end
end

# Viewer role gets read permissions this is for tentant1 
viewer_permissions = [perm2, perm3]
for perm <- viewer_permissions do
  case Repo.get_by(RolePermission, role_id: role2.id, permission_id: perm.id) do
    nil ->
      IO.puts("Granting permission #{perm.name} to role #{role2.name}")
      %RolePermission{}
      |> RolePermission.changeset(%{role_id: role2.id, permission_id: perm.id})
      |> Repo.insert!()
    existing ->
      IO.puts("Found existing role-permission: #{role2.name} <-> #{perm.name}")
      existing
  end
end

# Viewer role gets read permissions this is for tentant2
viewer_permissions = [perm2, perm3]
for perm <- viewer_permissions do
  case Repo.get_by(RolePermission, role_id: role3.id, permission_id: perm.id) do
    nil ->
      IO.puts("Granting permission #{perm.name} to role #{role3.name}")
      %RolePermission{}
      |> RolePermission.changeset(%{role_id: role3.id, permission_id: perm.id})
      |> Repo.insert!()
    existing ->
      IO.puts("Found existing role-permission: #{role3.name} <-> #{perm.name}")
      existing
  end
end

IO.puts("\n Database seeding completed successfully!")
IO.puts("=? Summary:")
IO.puts("    #{Repo.aggregate(Product, :count)} products")
IO.puts("    #{Repo.aggregate(Tenant, :count)} tenants")  
IO.puts("    #{Repo.aggregate(Plugin, :count)} plugins")
IO.puts("    #{Repo.aggregate(Permission, :count)} permissions")
IO.puts("    #{Repo.aggregate(User, :count)} users")
IO.puts("    #{Repo.aggregate(Role, :count)} roles")
IO.puts("    #{Repo.aggregate(Order, :count)} orders")
IO.puts("    #{Repo.aggregate(UserToken, :count)} user tokens")
IO.puts("    #{Repo.aggregate(TenantPlugin, :count)} tenant-plugin links")
IO.puts("    #{Repo.aggregate(UserRole, :count)} user-role assignments")
IO.puts("    #{Repo.aggregate(RolePermission, :count)} role-permission grants")

