# AGENTS.md

## Build/Test Commands
- `mix setup` - Install deps and setup all apps
- `mix test` - Run all tests
- `mix test apps/core/test/specific_test.exs` - Run single test file
- `mix format` - Format code (required before commits)
- `mix phx.server` - Start both Phoenix servers (inventory:4001, orders:4000)
- `cd apps/inventory && mix phx.server` - Start single app server

## Code Style Guidelines
- Use binary UUIDs as primary keys: `@primary_key {:id, :binary_id, autogenerate: true}`
- Import order: `use`, then `import`, then `alias` statements
- Use snake_case for variables, functions, and atoms
- Use PascalCase for module names
- Prefer explicit imports over wildcard imports
- Use `|>` pipe operator for data transformations
- Add `@doc` comments for public functions
- Use `@impl true` for callback implementations
- Validate required fields and constraints in changesets
- Use `Phoenix.PubSub.subscribe/2` for real-time updates
- Preload associations when needed: `Repo.preload(:association)`
- Use umbrella app dependencies: `{:core, in_umbrella: true}`
- Follow Phoenix LiveView patterns for real-time interfaces
- Use Ecto contexts for business logic organization
- Handle errors with pattern matching and proper error tuples