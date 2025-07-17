# Ensures Repo and dependencies are started
Mix.Task.run("app.start")

alias Core.Repo
alias Core.Accounts.{Tenant, User, Permission, Role}
alias Core.Accounts.{Roles, Permissions}
alias Core.Accounts

# Get existing records from database
tenant1 = Repo.get_by!(Tenant, name: "Tenant 1")
tenant2 = Repo.get_by!(Tenant, name: "Tenant 2")

# Get existing users
user1 = Repo.get_by!(User, name: "name1")
user2 = Repo.get_by!(User, name: "name2")
user3 = Repo.get_by!(User, name: "name3")

# Get existing permissions
create_order_perm = Repo.get_by!(Permission, name: "orders:create")
view_orders_perm = Repo.get_by!(Permission, name: "orders:view_all")
view_inventory_perm = Repo.get_by!(Permission, name: "inventory:view_all")

# Get existing roles
admin_role_t1 = Repo.get_by!(Role, name: "admin", tenant_id: tenant1.id)
admin_role_t2 = Repo.get_by!(Role, name: "admin", tenant_id: tenant2.id)
viewer_role_t1 = Repo.get_by!(Role, name: "viewer", tenant_id: tenant1.id)
viewer_role_t2 = Repo.get_by!(Role, name: "viewer", tenant_id: tenant2.id)

# # Add permissions to admin roles (both tenants)
# IO.puts("Adding permissions to admin_role_t1...")
# {:ok, admin_role_t1} = Roles.add_permission_to_role(admin_role_t1, create_order_perm)
# {:ok, admin_role_t1} = Roles.add_permission_to_role(admin_role_t1, view_orders_perm)
# {:ok, admin_role_t1} = Roles.add_permission_to_role(admin_role_t1, view_inventory_perm)
#
# IO.puts("Adding permissions to admin_role_t2...")
# {:ok, admin_role_t2} = Roles.add_permission_to_role(admin_role_t2, create_order_perm)
# {:ok, admin_role_t2} = Roles.add_permission_to_role(admin_role_t2, view_orders_perm)
# {:ok, admin_role_t2} = Roles.add_permission_to_role(admin_role_t2, view_inventory_perm)
#
# # Add permissions to viewer roles (both tenants)
# IO.puts("Adding permissions to viewer_role_t1...")
# {:ok, viewer_role_t1} = Roles.add_permission_to_role(viewer_role_t1, view_orders_perm)
# {:ok, viewer_role_t1} = Roles.add_permission_to_role(viewer_role_t1, view_inventory_perm)
#
# IO.puts("Adding permissions to viewer_role_t2...")
# {:ok, viewer_role_t2} = Roles.add_permission_to_role(viewer_role_t2, view_orders_perm)
# {:ok, viewer_role_t2} = Roles.add_permission_to_role(viewer_role_t2, view_inventory_perm)

# Assign roles to users
IO.puts("Assigning roles to users...")
{:ok, _user} = Accounts.assign_role_to_user(user1, admin_role_t1)
{:ok, _user} = Accounts.assign_role_to_user(user2, admin_role_t2)
{:ok, _user} = Accounts.assign_role_to_user(user3, viewer_role_t2)

IO.puts("Database population completed successfully!")

