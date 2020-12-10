defmodule Messaging.API.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Messaging.APIWeb.Endpoint

  def start(_type, _args) do
    children = [
      Endpoint,
      {Phoenix.PubSub, name: Messaging.API.PubSub}
    ]

    opts = [strategy: :one_for_one, name: Messaging.API.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
