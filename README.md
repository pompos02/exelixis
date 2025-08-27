# Exelixi Umbrella Project

A comprehensive multi-tenant business management system built with Elixir's Umbrella Project architecture. The system provides authentication, inventory management, and order processing capabilities across separate subdomain-based Phoenix applications.

## Architecture Overview

### Umbrella Project Structure
This project uses Elixir's Umbrella Project pattern to organize multiple related applications that can be developed, tested, and deployed independently while sharing common dependencies and configuration.

### OTP Applications

Each subdomain is powered by its own **independent OTP (Open Telecom Platform) application**, providing:
- **Fault Isolation**: If one app crashes, others continue running
- **Independent Supervision Trees**: Each app manages its own processes
- **Scalable Architecture**: Apps can be deployed to different servers
- **Clear Boundaries**: Business domains are cleanly separated

#### Core Applications:

1. **`core`** (`Core.Application`)
   - **Central Data Layer**: Houses all Ecto schemas and business logic contexts
   - **Shared Database**: Single PostgreSQL database (`exelixis_dev`) for all apps
   - **PubSub Hub**: Manages real-time communication via `Core.PubSub`
   - **Multi-Tenant Foundation**: Tenant isolation and role-based access control
   - **No HTTP Interface**: Pure business logic and data management

2. **`auth`** (`Auth.Application`) - Port 4003
   - **Authentication Hub**: User login, registration, and session management
   - **Subdomain**: `auth.exelixis.local:8000`
   - **Session Provider**: Issues authentication tokens shared across all apps
   - **User Management**: Account creation, password handling, profile management

3. **`inventory`** (`Inventory.Application`) - Port 4001
   - **Product Management**: Product catalog, stock levels, inventory tracking
   - **Subdomain**: `inventory.exelixis.local:8000`
   - **Real-Time Updates**: Live stock level changes via Phoenix LiveView
   - **Plugin-Gated**: Requires "inventory" plugin access at tenant level

4. **`orders`** (`Orders.Application`) - Port 4000
   - **Order Processing**: Order creation, customer management, fulfillment
   - **Subdomain**: `orders.exelixis.local:8000`
   - **Complex Transactions**: Atomic order creation with stock decrementation
   - **Plugin-Gated**: Requires "orders" plugin access at tenant level

5. **`shared_components`** (`SharedComponents.Application`)
   - **UI Component Library**: Reusable Phoenix LiveView components
   - **Cross-App Consistency**: Shared styling and component patterns
   - **No HTTP Interface**: Pure component library

## Reverse Proxy Architecture

### Caddy Server Configuration
The project uses **Caddy** as a reverse proxy to route subdomain requests to the appropriate Phoenix applications.

**Configuration File**: `Caddyfile`

```
:8000 {
    # inventory.exelixis.local → 127.0.0.1:4001
    @inventory host inventory.exelixis.local
    handle @inventory {
        reverse_proxy 127.0.0.1:4001
    }

    # orders.exelixis.local → 127.0.0.1:4000  
    @orders host orders.exelixis.local
    handle @orders {
        reverse_proxy 127.0.0.1:4000
    }

    # auth.exelixis.local → 127.0.0.1:4003
    @auth host auth.exelixis.local
    handle @auth {
        reverse_proxy 127.0.0.1:4003
    }
}
```

### Reverse Proxy Benefits:
- **Single Entry Point**: All traffic routes through port 8000
- **SSL Termination**: Caddy can handle HTTPS certificates
- **Load Balancing**: Can distribute traffic across multiple instances
- **Header Forwarding**: Preserves original client information
- **WebSocket Support**: Handles Phoenix LiveView real-time connections

## Subdomain Cookie Sharing Architecture

### Cross-Subdomain Session Management
The system implements sophisticated cross-subdomain authentication using shared session cookies.

#### Session Configuration (`*.exelixis.local`)

**Shared Configuration Across All Apps**:
```elixir
@session_options [
  store: :cookie,
  key: "_exelixi_apps_key",              # Same key across all apps
  signing_salt: "shared_session_salt_2024", # Shared salt for security
  same_site: "Lax"
]

def session_opts() do
  domain = ".exelixis.local"             # Leading dot enables subdomain sharing
  Keyword.put(@session_options, :domain, domain)
end
```

#### Critical Implementation Details:

1. **Domain Setting**: `.exelixis.local` (with leading dot)
   - Enables cookie sharing across all `*.exelixis.local` subdomains
   - Without the dot, cookies would be isolated per subdomain

2. **Shared Secret Key**: `tUS/5irgVLa6bMOkdnZDlgzKicjcRWONJKuJcwYYKJy9T1mTHBmcImiRnpVh429O`
   - All apps use the same `secret_key_base` for session encryption
   - Defined in `config/dev.exs` as `shared_secret_key_base`

3. **Session Persistence**: Database-backed tokens
   - Sessions stored in `user_tokens` table with 24-hour expiry
   - More secure than cookie-only sessions
   - Allows individual session revocation

### Authentication Flow:
```
1. User logs in at auth.exelixis.local
2. Session cookie set with domain=".exelixis.local"
3. User navigates to inventory.exelixis.local
4. Browser sends same session cookie
5. inventory app validates session against Core.Repo
6. User is authenticated without re-login
```

## Multi-Tenant Security Architecture

### Two-Layer Access Control:

#### 1. Plugin-Level Access (Tenant-Based)
- **Purpose**: Controls which Phoenix apps users can access
- **Managed By**: Tenant-to-Plugin relationships in database
- **Implementation**: Router-level plugs (`:require_inventory_access`, `:require_orders_access`)

#### 2. Route-Level Access (Permission-Based)  
- **Purpose**: Controls specific actions within apps
- **Managed By**: User → Role → Permission relationships
- **Implementation**: `:require_permission` plug with granular permissions

### Database Schema Architecture

The system uses a sophisticated multi-tenant database schema with role-based access control:

#### Core Tables:
- **`tenants`**: Organization isolation layer
- **`users`**: Belongs to exactly one tenant
- **`user_tokens`**: Database-backed session management (24hr expiry)
- **`roles`**: Tenant-scoped roles (same role name can exist in different tenants)
- **`permissions`**: Granular access control ("orders:create", "inventory:view")
- **`plugins`**: Feature gates ("inventory", "orders")

#### Business Domain:
- **`products`**: Inventory items with stock levels
- **`orders`**: Customer orders with atomic stock decrementation

## Development Setup

### Prerequisites:
- Elixir 1.14+ with Phoenix 1.7+
- PostgreSQL database
- Caddy web server
- Node.js (for asset compilation)

### Local Development Domains:
Add to `/etc/hosts`:
```
127.0.0.1 inventory.exelixis.local
127.0.0.1 orders.exelixis.local  
127.0.0.1 auth.exelixis.local
```

### Commands:

```bash
# Install dependencies for all apps
mix setup

# Start all Phoenix servers
mix phx.server

# Or start individual apps
cd apps/inventory && mix phx.server  # Port 4001
cd apps/orders && mix phx.server     # Port 4000  
cd apps/auth && mix phx.server       # Port 4003

# Start Caddy reverse proxy
caddy run --config Caddyfile         # Port 8000

# Run tests
mix test

# Format code
mix format
```

### Application URLs:
- **Main Access**: http://localhost:8000 (via Caddy)
- **Auth**: http://auth.exelixis.local:8000
- **Inventory**: http://inventory.exelixis.local:8000  
- **Orders**: http://orders.exelixis.local:8000

Direct Phoenix URLs (bypassing Caddy):
- **Auth**: http://localhost:4003
- **Inventory**: http://localhost:4001
- **Orders**: http://localhost:4000

## Key Features

### Multi-Tenant Architecture
- **Tenant Isolation**: Each user belongs to exactly one tenant
- **Plugin System**: Tenant-level feature access control
- **Role-Based Permissions**: Granular route-level access control
- **Cross-App Authentication**: Single sign-on across all subdomains

### Real-Time Features
- **Phoenix LiveView**: Real-time UI updates without JavaScript
- **PubSub Communication**: Cross-app event broadcasting
- **Live Dashboards**: Real-time system monitoring
- **WebSocket Support**: Persistent connections via Phoenix Channels

### Business Capabilities
- **Inventory Management**: Product catalog, stock tracking, real-time updates
- **Order Processing**: Complex order creation with atomic stock transactions
- **User Management**: Authentication, authorization, profile management
- **Audit Trail**: Comprehensive logging and change tracking

## Project Structure

```
exelixi_umbrella/
├── apps/
│   ├── core/                    # Data layer & business logic
│   │   ├── lib/core/
│   │   │   ├── accounts/        # User, tenant, role management  
│   │   │   ├── products.ex      # Product context
│   │   │   ├── orders.ex        # Order context
│   │   │   └── repo.ex          # Database access
│   │   └── priv/repo/migrations/ # Database schema
│   │
│   ├── auth/                    # Authentication app (Port 4003)
│   │   ├── lib/auth_web/        # Phoenix web interface
│   │   └── assets/              # CSS/JS assets
│   │
│   ├── inventory/               # Inventory app (Port 4001)  
│   │   ├── lib/inventory_web/   # Phoenix web interface
│   │   └── assets/              # CSS/JS assets
│   │
│   ├── orders/                  # Orders app (Port 4000)
│   │   ├── lib/orders_web/      # Phoenix web interface  
│   │   └── assets/              # CSS/JS assets
│   │
│   └── shared_components/       # Shared UI components
│       └── lib/shared_components/
│
├── config/                      # Shared configuration
│   ├── config.exs              # Base config for all apps
│   ├── dev.exs                 # Development environment
│   └── prod.exs                # Production environment
│
├── Caddyfile                   # Reverse proxy configuration
├── mix.exs                     # Umbrella project definition
└── README.md                   # This file
```

## Technical Implementation Notes

### Umbrella Dependencies:
- **In-Umbrella References**: `{:core, in_umbrella: true}`
- **Shared Configuration**: All apps use same `config/` directory
- **Unified Dependencies**: Common packages managed at umbrella level

### Database Strategy:
- **Single Database**: `exelixis_dev` shared across all apps
- **Core Ownership**: Only `core` app defines Ecto schemas
- **Context Pattern**: Business logic encapsulated in contexts

### Session Security:
- **Shared Secret**: Enables cross-app session decryption
- **Database Tokens**: More secure than cookie-only sessions
- **Automatic Expiry**: 24-hour token lifecycle
- **Domain Scoping**: Cookies limited to `*.exelixis.local`

### Phoenix LiveView Integration:
- **Real-Time UI**: No JavaScript required for dynamic interfaces
- **Shared Components**: Reusable across all apps
- **WebSocket Connections**: Handled transparently by Phoenix

This architecture provides a scalable, maintainable foundation for multi-tenant business applications with clear separation of concerns, robust security, and seamless user experience across multiple domains.