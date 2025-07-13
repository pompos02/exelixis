defmodule Orders.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OrdersWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:orders, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Orders.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Orders.Finch},
      # Start a worker by calling: Orders.Worker.start_link(arg)
      # {Orders.Worker, arg},
      # Start to serve requests, typically the last entry
      OrdersWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Orders.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OrdersWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
