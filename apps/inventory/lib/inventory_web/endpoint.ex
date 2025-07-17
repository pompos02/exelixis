defmodule InventoryWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :inventory

  # Base session configuration for cross-app session sharing
  @session_options [
    store: :cookie,
    key: "_exelixi_apps_key",
    signing_salt: "shared_session_salt_2024",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: {__MODULE__, :session_opts, []}]],
    longpoll: [connect_info: [session: {__MODULE__, :session_opts, []}]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :inventory,
    gzip: false,
    only: InventoryWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug :session
  plug InventoryWeb.Router

  def session(conn, _opts) do
    opts = session_opts()
    Plug.Session.call(conn, Plug.Session.init(opts))
  end

  def session_opts() do
    # Set domain to top-level domain for subdomain cookie sharing
    # The key insight: use the top-level domain (localhost) so cookies work across subdomains
    domain = "localhost"
    Keyword.put(@session_options, :domain, InventoryWeb.Endpoint.host())
  end
end
