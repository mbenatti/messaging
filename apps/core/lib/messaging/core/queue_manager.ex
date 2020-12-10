defmodule Messaging.Core.QueueManager do
  @moduledoc """
  Queue Manager is a Supervisor responsible to manage the Queues,
  The main responsibility is start new `Messaging.Core.Queue`, supervise it and delegate to enqueue new message
  """

  alias Messaging.Core.Queue

  @doc """
  Verify if the Queue exists, start it if not exist and call :enqueue on the `Messaging.Core.Queue`
  """
  @spec enqueue(String.t(), String.t()) :: :ok
  def enqueue(queue, message) do
    queue
    |> Queue.queue_name()
    |> queue_exist?()
    |> do_enqueue(message)
  end

  defp do_enqueue({true, queue_name}, message) do
    GenServer.cast(Queue.via_tuple(queue_name), {:enqueue, message})
  end

  defp do_enqueue({false, queue_name}, message) do
    start_queue(queue_name)

    GenServer.cast(Queue.via_tuple(queue_name), {:enqueue, message})
  end

  @doc """
  Starts a `Messaging.Core.Queue` process and supervises it.
  """
  @spec start_queue(String.t()) :: DynamicSupervisor.on_start_child()
  def start_queue(queue_name) do
    child_spec = %{
      id: Queue,
      start: {Queue, :start_link, [queue_name]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  defp queue_exist?(queue) do
    case Registry.lookup(Messaging.QueuesRegistry, queue) do
      [] -> {false, queue}
      [{_pid, _}] -> {true, queue}
    end
  end
end
