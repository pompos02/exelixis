defmodule Core.SharedSession do
  @moduledoc """
  Shared session configuration for all Phoenix apps in the umbrella.
  Provides consistent session options across auth, orders, and inventory apps.
  """

  @session_options [
    store: :cookie,
    key: "_exelixi_session",
    signing_salt: "shared_session_salt_2024",
    domain: "localhost",  # No leading dot as per modern browser specs
    same_site: "Lax"
  ]

  def session_options, do: @session_options
end