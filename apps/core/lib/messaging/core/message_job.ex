defmodule Messaging.Core.MessageJob do
  @moduledoc """
  Async `Task` to Process the Message
  """

  use Task

  require Logger

  @doc """
  Start the MessageJob
  """
  @spec start(String.t(), String.t()) :: Task.t()
  def start(queue, msg) do
    Task.Supervisor.async_nolink(Messaging.MessageJobSupervisor, __MODULE__, :run, [queue, msg])
  end

  @doc """
  Do whatever you want with the message
  """
  @spec run(String.t(), String.t()) :: :success
  def run(queue, msg) do
    # Processing the message
    # Some logic ex. save on db, etc.
    Logger.info("MessageJob - Queue: #{queue} -> Msg: #{msg}")

    :success
  end
end
