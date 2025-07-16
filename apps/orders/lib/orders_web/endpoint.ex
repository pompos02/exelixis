defmodule OrdersWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :orders

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
    from: :orders,
    gzip: false,
    only: OrdersWeb.static_paths()

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
  plug OrdersWeb.Router

  def session(conn, _opts) do
    opts = session_opts()
    Plug.Session.call(conn, Plug.Session.init(opts))
  end

  def session_opts() do
    # Extract top-level domain from host for subdomain cookie sharing
    host = OrdersWeb.Endpoint.host()
    domain = extract_top_level_domain(host)
    Keyword.put(@session_options, :domain, domain)
  end

  defp extract_top_level_domain(host) do
    # For localhost development: localhost
    # For production: extract top-level domain (e.g., example.com from tenant.example.com)
    case host do
      "localhost" -> "localhost"
      _ ->
        host
        |> String.split(".")
        |> case do
          [_single] -> host  # single domain
          parts when length(parts) >= 2 ->
            parts
            |> Enum.take(-2)  # Take last 2 parts (domain.tld)
            |> Enum.join(".")
          _ -> host
        end
    end
  end
end
