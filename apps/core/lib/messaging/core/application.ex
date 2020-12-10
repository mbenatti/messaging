defmodule Messaging.Core.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Messaging.QueuesRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Messaging.Core.QueueManager},
      {Task.Supervisor, name: Messaging.MessageJobSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Messaging.Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
