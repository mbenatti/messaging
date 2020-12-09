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
    case queue_exist?(queue) do
      true ->
        GenServer.cast(Queue.via_tuple(queue), {:enqueue, message})

      false ->
        start_queue(queue)

        GenServer.cast(Queue.via_tuple(queue), {:enqueue, message})
    end
  end

  @doc """
  Starts a `Messaging.Core.Queue` process and supervises it.
  """
  def start_queue(queue_name) do
    child_spec = %{
      id: Queue,
      start: {Queue, :start_link, [queue_name]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  defp queue_exist?(queue) do
    case Registry.lookup(Messaging.QueueRegistry, Queue.queue_name(queue)) do
      [] -> false
      [{_pid, _}] -> true
    end
  end
end
