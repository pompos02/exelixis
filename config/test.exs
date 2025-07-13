import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :orders, OrdersWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "dXwHbjnakrS+CrTeoFu+fljpGwTJ2zLwcQLxB/DGZ4sk9dCv9f9iZWjYFUGjuAtD",
  server: false

# In test we don't send emails
config :orders, Orders.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :inventory, InventoryWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "WMVFo0WsI8AuQmqnBf5jRZv5IKRdQ7kJjpoL8noPgkVZgYa/VA7R1R1STYVmhEnn",
  server: false

# In test we don't send emails
config :inventory, Inventory.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exelixi_web, ExelixiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "rGu5gl6dM67benyM0t4BgUrUIJ+HHoAw/s+VrjkewnKnJWONUvGuJpDk1Qb6zWkR",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# In test we don't send emails
config :exelixi, Exelixi.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
