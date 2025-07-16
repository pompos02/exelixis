defmodule Core.SessionPlug do
  @moduledoc """
  Custom session plug that provides runtime domain configuration for session sharing
  across all Phoenix apps in the umbrella. This plug wraps Plug.Session to enable
  cross-subdomain session sharing.
  """

  def init(opts), do: opts

  def call(conn, _opts) do
    session_opts = [
      store: :cookie,
      key: "_exelixi_session",
      signing_salt: "shared_session_salt_2024",
      domain: get_domain(),
      same_site: "Lax"
    ]

    Plug.Session.call(conn, Plug.Session.init(session_opts))
  end

  defp get_domain do
    case System.get_env("SESSION_DOMAIN") do
      nil -> "localhost"  # No leading dot as per modern browser specs
      domain -> domain
    end
  end
end