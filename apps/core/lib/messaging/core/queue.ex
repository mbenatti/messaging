defmodule Messaging.Core.Queue do
  @moduledoc """
  Represent a Queue, each queue is a Process and contains the logic to process a message on a given interval
  """

  use GenServer

  @prefix "queue_"

  require Logger

  alias Messaging.Core.MessageJob

  @doc """
  Spawns a new queue server process registered under the given `queue_name`.
  """
  def start_link(queue_name) do
    GenServer.start_link(__MODULE__, queue_name, name: via_tuple(queue_name))
  end

  @doc """
  Init the Queue with a `:queue` as State to control the messages
  """
  def init(queue_name) do
    queue = :queue.new()

    :timer.send_interval(get_interval(), :process)

    {:ok, %{queue: queue, name: queue_name}}
  end

  @doc """
  Enqueue the msg on the state `:queue`
  """
  def handle_cast({:enqueue, msg}, %{queue: queue} = state) do
    new_queue = :queue.in(msg, queue)

    {:noreply, %{state | queue: new_queue}}
  end

  @doc """
  Process the message on each second( or other interval, provided by `:message_interval` config
  """
  def handle_info(:process, %{queue: queue, name: name} = state) do
    new_queue =
      case :queue.out(queue) do
        {{:value, message}, queue} ->
          MessageJob.start(name, message)
          queue

        {:empty, queue} ->
          #          Logger.info("The queue: #{name} is empty")

          queue
      end

    {:noreply, %{state | queue: new_queue}}
  end

  # Callback The MessageJob completed successfully
  @doc false
  def handle_info({_ref, _answer}, state) do
    # Log and/or possible do something and/or notify someone with the result(_answer)

    {:noreply, state}
  end

  # Callback The MessageJob failed
  @doc false
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    # Log and/or possibly alert someone that processing are failing

    {:noreply, state}
  end

  @doc """
  Returns a tuple used to register and lookup a queue process by name.
  """
  @spec via_tuple(String.t()) :: tuple
  def via_tuple(name) do
    {:via, Registry, {Messaging.QueuesRegistry, name}}
  end

  @doc """
  Util to append a prefix to queue name, the idea is to use it internally to not conflict with reserved names
  """
  @spec queue_name(String.t()) :: String.t()
  def queue_name(queue) do
    @prefix <> queue
  end

  defp get_interval do
    Application.get_env(:core, :message_interval, 1000)
  end
end
