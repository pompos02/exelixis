
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
iasonas = Repo.get_by!(User, name: "iasonas")

# Get existing roles
admin_role_t1 = Repo.get_by!(Role, name: "admin", tenant_id: tenant1.id)
admin_role_t2 = Repo.get_by!(Role, name: "admin", tenant_id: tenant2.id)

viewer_role_t1 = Repo.get_by!(Role, name: "viewer", tenant_id: tenant1.id)
viewer_role_t2 = Repo.get_by!(Role, name: "viewer", tenant_id: tenant2.id)

IO.puts("Assigning roles to users...")
{:ok, _user} = Accounts.assign_role_to_user(iasonas, viewer_role_t1)

IO.puts("Database population completed successfully!")

