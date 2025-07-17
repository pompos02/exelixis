# Ensures Repo and dependencies are started
Mix.Task.run("app.start")

alias Core.Repo

alias Core.Accounts.{Tenant, User, Plugin, TenantPlugin, Role, Roles, RolePermission, Permissions}
alias Core.Accounts

tenant1 = Repo.get_by!(Tenant, name: "Tenant 1")
tenant2 = Repo.get_by!(Tenant, name: "Tenant 2")
# belongs to tenant1
user1 = Repo.get_by!(User, name: "name1")
# belongs to tenant2
user2 = Repo.get_by!(User, name: "name2")
# belongs to tenant2
user3 = Repo.get_by!(User, name: "name3")

{:ok, create_order_perm} =
  Permissions.create_permission(%{name: "orders:create"})

{:ok, view_orders_perm} =
  Permissions.create_permission(%{name: "orders:view_all"})

# Create permissions for the inventory plugin
{:ok, view_inventory_perm} =
  Permissions.create_permission(%{
    name: "inventory:view_all"
  })

# An Admin role for the tenant
{:ok, admin_role_t1} = Roles.create_role(%{name: "admin", tenant_id: tenant1.id})
{:ok, admin_role_t2} = Roles.create_role(%{name: "admin", tenant_id: tenant2.id})
# A limited Viewer role for the tenant
{:ok, viewer_role_t1} = Roles.create_role(%{name: "viewer", tenant_id: tenant1.id})
{:ok, viewer_role_t2} = Roles.create_role(%{name: "viewer", tenant_id: tenant2.id})

# The Admin role gets all permissions
{:ok, admin_role_t1} = Roles.add_permission_to_role(admin_role_t1, create_order_perm)
{:ok, admin_role_t1} = Roles.add_permission_to_role(admin_role_t1, view_orders_perm)
{:ok, admin_role_t1} = Roles.add_permission_to_role(admin_role_t1, view_inventory_perm)

# The Admin role gets all permissions
{:ok, admin_role_t2} = Roles.add_permission_to_role(admin_role_t2, create_order_perm)
{:ok, admin_role_t2} = Roles.add_permission_to_role(admin_role_t2, view_orders_perm)
{:ok, admin_role_t2} = Roles.add_permission_to_role(admin_role_t2, view_inventory_perm)
# The Viewer role only gets viewing permissions
{:ok, viewer_role_t1} = Roles.add_permission_to_role(viewer_role_t1, view_orders_perm)
{:ok, viewer_role_t1} = Roles.add_permission_to_role(viewer_role_t1, view_inventory_perm)

{:ok, viewer_role_t2} = Roles.add_permission_to_role(viewer_role_t2, view_orders_perm)
{:ok, viewer_role_t2} = Roles.add_permission_to_role(viewer_role_t2, view_inventory_perm)

{:ok, _user} = Accounts.assign_role_to_user(user1, admin_role_t1)
{:ok, _user} = Accounts.assign_role_to_user(user2, admin_role_t2)
{:ok, _user} = Accounts.assign_role_to_user(user3, viewer_role_t2)
