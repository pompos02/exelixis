  PRIMARY SCHEMAS & TABLES

  1. AUTHENTICATION & SESSION MANAGEMENT

  👤 User Schema (users table)

  # Location: apps/core/lib/core/accounts/user.ex
  Primary Key: Binary UUID (@primary_key {:id, :binary_id, autogenerate: true})

  Core Fields:
  - email (string) - Unique constraint, validated format
  - name (string) - Unique constraint, 2-100 chars, alphanumeric + underscore + spaces
  - password (virtual, redacted) - Not stored in DB
  - hashed_password (string, redacted) - Bcrypt hashed password
  - current_password (virtual, redacted) - For password validation
  - tenant_id (binary_id foreign key) - Links to tenant

  Relationships:
  - belongs_to :tenant → Links user to their organization
  - has_many :tokens → Session tokens for authentication
  - has_many :user_roles → Join table to roles
  - has_many :roles, through: [:user_roles, :role] → Many-to-many with roles

  Validation Logic:
  - Email: Must have @ sign, no spaces, max 160 chars
  - Password: Min 8 chars, max 72 chars, Bcrypt hashed
  - Name: 2-100 chars, unique, alphanumeric pattern
  - Both email and name have unique constraints

  🔑 UserToken Schema (users_tokens table)

  # Location: apps/core/lib/core/accounts/user_token.ex
  Primary Key: Binary UUID

  Core Fields:
  - token (binary) - 32-byte random token
  - context (string) - Always "session"
  - sent_to (string) - Not used in current implementation
  - user_id (binary_id foreign key) - Links to user
  - inserted_at (utc_datetime) - For expiration checking

  Session Management:
  - Session Validity: 24 hours (@session_validity_in_hours 24)
  - Token Generation: Uses :crypto.strong_rand_bytes(32)
  - Verification: Checks token exists AND is not expired
  - Security: Tokens stored in database for individual session expiration

  ---
  2. MULTI-TENANT ARCHITECTURE

  🏢 Tenant Schema (tenants table)

  # Location: apps/core/lib/core/accounts/tenant.ex
  Primary Key: Binary UUID

  Core Fields:
  - name (string) - Unique constraint, 2-100 chars

  Relationships:
  - has_many :users → All users belonging to this tenant
  - has_many :tenant_plugins → Join table to plugins
  - has_many :plugins, through: [:tenant_plugins, :plugin] → Available plugins

  Business Logic:
  - Tenant Isolation: Each user belongs to exactly one tenant
  - Plugin Access: Controlled at tenant level (not user level)
  - Naming: Unique tenant names across the system

  ---
  3. ROLE-BASED ACCESS CONTROL (RBAC)

  👥 Role Schema (roles table)

  # Location: apps/core/lib/core/accounts/role.ex
  Primary Key: Binary UUID

  Core Fields:
  - name (string) - Role name (admin, viewer, etc.)
  - tenant_id (binary_id foreign key) - TENANT-SCOPED ROLES

  Relationships:
  - belongs_to :tenant → Roles are tenant-specific
  - has_many :user_roles → Join table to users
  - has_many :users, through: [:user_roles, :user] → Users with this role
  - has_many :role_permissions → Join table to permissions
  - has_many :permissions, through: [:role_permissions, :permission] → Role's permissions

  Critical Architecture Decision:
  - Tenant-Scoped Roles: Same role name can exist in different tenants (e.g., "admin" in Tenant1 vs "admin" in Tenant2)

  🔐 Permission Schema (permissions table)

  # Location: apps/core/lib/core/accounts/permission.ex
  Primary Key: Binary UUID

  Core Fields:
  - name (string) - Structured format: "resource:action"

  Validation:
  - Format Validation: Must match regex /^[a-z_]+:[a-z_]+$/
  - Examples: "orders:create", "inventory:view_all", "products:delete"
  - Unique Constraint: No duplicate permissions

  Relationships:
  - has_many :role_permissions → Join table to roles
  - has_many :roles, through: [:role_permissions, :role] → Roles with this permission

  ---
  4. JOIN TABLES (ASSOCIATION MANAGEMENT)

  🔗 UserRole Join Table (users_roles table)

  # Location: apps/core/lib/core/accounts/user_role.ex
  Primary Key: Binary UUID (Has its own ID)

  Join Fields:
  - user_id (binary_id foreign key)
  - role_id (binary_id foreign key)
  - Unique Constraint: [:user_id, :role_id] - Prevents duplicate assignments

  🔗 RolePermission Join Table (roles_permissions table)

  # Location: apps/core/lib/core/accounts/role_permission.ex
  Primary Key: Composite (@primary_key false)
  - role_id (binary_id, primary_key: true)
  - permission_id (binary_id, primary_key: true)

  Unique Constraint: [:role_id, :permission_id]

  🔗 TenantPlugin Join Table (tenants_plugins table)

  # Location: apps/core/lib/core/accounts/tenant_plugin.ex
  Primary Key: Composite (@primary_key false) ⚠️ ISSUE DETECTED
  - tenant_id (binary_id, primary_key: true)
  - plugin_id (binary_id, primary_key: true)

  ⚠️ CRITICAL ISSUE: This schema causes Ecto preloading errors because Ecto expects at least one traditional primary key field for
  preloading associations.

  ---
  5. PLUGIN SYSTEM

  🔌 Plugin Schema (plugins table)

  # Location: apps/core/lib/core/accounts/plugin.ex
  Primary Key: Binary UUID

  Core Fields:
  - name (string) - Plugin identifier ("inventory", "orders")

  Relationships:
  - has_many :tenant_plugins → Join table to tenants
  - has_many :tenants, through: [:tenant_plugins, :tenant] → Tenants with access

  Business Logic:
  - Feature Gating: Controls which Phoenix apps tenants can access
  - Current Plugins: "inventory" and "orders"

  ---
  6. BUSINESS DOMAIN SCHEMAS

  📦 Product Schema (products table)

  # Location: apps/core/lib/core/product.ex
  Primary Key: Binary UUID

  Core Fields:
  - name (string) - Unique constraint
  - stock_level (integer) - Default: 0

  Relationships:
  - has_many :orders → Orders for this product

  📋 Order Schema (orders table)

  # Location: apps/core/lib/core/order.ex
  Primary Key: Binary UUID

  Core Fields:
  - customer_name (string) - Required
  - product_quantity (integer) - Must be > 0
  - product_id (binary_id foreign key) - Links to product

  Relationships:
  - belongs_to :product → The ordered product

  Business Logic:
  - Stock Management: Order creation decrements product stock_level
  - Validation: Quantity must be positive
  - Ordering: Orders returned newest first (order_by(desc: :inserted_at))

  ---
  🔄 RELATIONSHIP FLOW DIAGRAMS

  Multi-Tenant Permission Flow:

  User → Tenant → TenantPlugin → Plugin (Feature Access)
  User → UserRole → Role → RolePermission → Permission (Route Access)

  Authentication Flow:

  User → UserToken (Session) → 24-hour expiry

  Business Domain Flow:

  Order → Product (Stock decremented on order creation)

  ---
  🛠️ CONTEXT FUNCTIONS & BUSINESS LOGIC

  Core.Accounts Context Functions:

  Plugin Access Control:

  # Tenant-level plugin access
  def tenant_has_plugin?(tenant, plugin_name)
    # Preloads plugins and checks if plugin exists

  # User-level plugin access (via tenant)
  def user_has_plugin?(user, plugin_name)
    # Gets user's tenant, then checks tenant_has_plugin?

  # Specific plugin checks
  def user_can_access_inventory?(user)
  def user_can_access_orders?(user)

  Permission Control:

  # Role-based permission checking
  def user_has_permission?(user, permission_name)
    # Preloads user → roles → permissions
    # Flattens all permissions and checks for match

  Role Management:

  def assign_role_to_user(user, role)
    # Creates UserRole association if it doesn't exist
    # Prevents duplicate role assignments

  Authentication Functions:

  - get_user_by_email/1
  - get_user_by_name/1
  - get_user_by_email_and_password/2
  - get_user_by_name_and_password/2

  Core.Products Context:

  def list_products/0    # Lists all products
  def get_product/1      # Gets single product by ID
  def create_product/1   # Creates new product

  Core.Orders Context:

  def list_orders/0      # Lists orders (newest first)
  def get_order/1        # Gets single order by ID
  def create_order/1     # COMPLEX TRANSACTION LOGIC

  Advanced Order Creation Logic:

  def create_order(attrs) do
    Multi.new()
    |> Multi.run(:product, fn -> fetch_product end)
    |> Multi.run(:order_changeset, fn -> validate_stock end)
    |> Multi.insert(:order, fn -> insert_order end)
    |> Multi.update(:product_update, fn -> decrement_stock end)
    |> Repo.transaction()
  end

  Transaction Steps:
  1. Fetch Product: Verify product exists
  2. Stock Validation: Check sufficient inventory
  3. Order Creation: Insert order record
  4. Stock Update: Decrement product stock_level
  5. PubSub Notifications: Broadcast order_created and product_updated events

  ---
  🔐 SECURITY & ACCESS CONTROL PATTERNS

  Two-Level Access Control:

  1. Plugin Level (Tenant-based):
    - Controls which Phoenix apps users can access
    - Managed in router via :require_inventory_access, :require_orders_access
  2. Route Level (Permission-based):
    - Controls specific actions within apps
    - Managed via :require_permission plug with permission names

  Authentication Architecture:

  - Session Storage: Database-backed tokens (not just cookies)
  - Cross-Subdomain: Shared sessions across *.exelixis.local
  - Expiry Management: 24-hour token validity with automatic cleanup

  Multi-Tenancy Isolation:

  - User Isolation: Each user belongs to exactly one tenant
  - Role Scoping: Roles are tenant-specific (no cross-tenant role sharing)
  - Plugin Access: Managed at tenant level for organizational control
