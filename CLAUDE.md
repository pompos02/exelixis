# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Elixir umbrella project called "Exelixi" containing three main applications:

- **Core**: Shared business logic and database layer (Ecto schemas, contexts). Contains Product and Order schemas with their respective contexts.
- **Inventory**: Phoenix web application for inventory management (runs on localhost:4001)
- **Orders**: Phoenix web application for order management (runs on localhost:4000)

The project uses PostgreSQL with Ecto for data persistence and Phoenix LiveView for interactive web interfaces.

## Common Development Commands

### Setup and Dependencies
```bash
# Install dependencies and setup all apps
mix setup

# Install dependencies only  
mix deps.get
```

### Database Operations
```bash
# Create and migrate database (from umbrella root)
mix ecto.create
mix ecto.migrate

# Run migrations for specific app
cd apps/core && mix ecto.migrate
```

### Development Servers
```bash
# Start both servers from umbrella root
mix phx.server 

# Start inventory app server (localhost:4001)
cd apps/inventory && mix phx.server

# Start orders app server (localhost:4000)
cd apps/orders && mix phx.server
```

### Asset Management
```bash
# Build assets for inventory app
cd apps/inventory && mix assets.build

# Build assets for orders app
cd apps/orders && mix assets.build

# Setup assets (install tailwind/esbuild)
cd apps/inventory && mix assets.setup
cd apps/orders && mix assets.setup
```

### Testing
```bash
# Run all tests
mix test

# Run tests for specific app
cd apps/core && mix test
cd apps/inventory && mix test
cd apps/orders && mix test
```

### Code Quality
```bash
# Format code
mix format

# Check formatting
mix format --check-formatted
```

## Architecture Notes

- **Umbrella Structure**: All apps share the same `_build`, `deps`, `config`, and `mix.lock` at the umbrella root
- **Database Configuration**: Core app manages the Ecto repo (`Core.Repo`) used by other apps
- **Inter-app Dependencies**: Both inventory and orders apps depend on the core app via `{:core, in_umbrella: true}`
- **Binary IDs**: The project uses binary UUIDs as primary keys (`@primary_key {:id, :binary_id, autogenerate: true}`)
- **Shared Config**: All apps share configuration files in `/config/` at umbrella root
- **PubSub Configuration**: Single PubSub server (`Core.PubSub`) started in Core.Application supervision tree, used by all Phoenix apps for real-time communication

## Database Schema

- **Products table**: Managed by Core.Product schema with:
  - `id`: binary UUID primary key
  - `name`: string, unique, not null
  - `stock_level`: integer, default: 0, not null
  - `inserted_at`, `updated_at`: timestamps
  - Has many orders relationship
  
- **Orders table**: Managed by Core.Order schema with:
  - `id`: binary UUID primary key
  - `customer_name`: string, not null
  - `product_quantity`: integer, not null (must be > 0)
  - `product_id`: UUID foreign key referencing products.id
  - `inserted_at`, `updated_at`: timestamps
  - Belongs to product relationship
  - **Ordering**: Orders are returned newest first (ordered by `inserted_at DESC`)
  
- Uses PostgreSQL with binary UUID primary keys
- Database repo is Core.Repo (configured in core app)
- Foreign key constraint: orders.product_id references products.id
- Indexes: unique on products.name, standard on orders.product_id

## Phoenix Apps Configuration

- **Inventory App**: Endpoint at InventoryWeb.Endpoint (port 4001), uses Bandit adapter
- **Orders App**: Endpoint at OrdersWeb.Endpoint (port 4000), uses Bandit adapter
- **PubSub**: Centralized PubSub server (`Core.PubSub`) configured in Core.Application, shared across all apps
- Both apps use Tailwind CSS and esbuild for asset compilation
- LiveView signing salts are different for each app
- LiveView modules subscribe to "orders" topic for real-time updates

## Asset Pipeline

- **esbuild**: Configured for both inventory and orders apps with external Phoenix dependencies
- **Tailwind**: Separate configurations for each app with dedicated input/output paths
- Assets are built to `priv/static/assets/` in each app
