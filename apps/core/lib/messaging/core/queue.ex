defmodule Messaging.Core.Queue do
  use GenServer

  @prefix "queue_"

  require Logger

  alias Messaging.Core.MessageJob

  @doc """
  Spawns a new queue server process registered under the given `queue_name`.
  """
  def start_link(queue_name) do
    GenServer.start_link(__MODULE__,
      [],
      name: via_tuple(queue_name))
  end

  @doc """
  Init the Queue with a `:queue` as State to control the messages
  """
  def init(_) do
    queue = :queue.new()

    Process.send_after(self(), :process_message, get_interval())

    {:ok, queue}
  end

  @doc """
  Enqueue the msg on the state `:queue`
  """
  def handle_cast({:enqueue, msg}, queue) do
    new_queue = :queue.in(msg, queue)

    {:noreply, new_queue}
  end

  @doc """
  Process the message on each second( or other interval, provided by `:message_interval` config
  """
  def handle_info(:process_message, queue) do
    new_queue = case :queue.out(queue) do
      {{:value, message}, queue} ->
        MessageJob.start(my_queue_name(), message)
        queue

      {:empty, queue} ->
#        Logger.debug("The queue: #{my_queue_name()} is empty}")

        queue
    end

    Process.send_after(self(), :process_message, get_interval())

    {:noreply, new_queue}
  end

  # Callback The MessageJob completed successfully
  @doc false
  def handle_info({ref, _answer}, state) do
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(ref, [:flush])
    # Possible Do something with the result and then return
    {:noreply, state}
  end

  # Callback The MessageJob failed
  @doc false
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    # Log and possibly restart the MessageJob...
    {:noreply, state}
  end

  @doc """
  Returns a tuple used to register and lookup a queue process by name.
  """
  def via_tuple(name) do
    {:via, Registry, {Messaging.QueueRegistry, queue_name(name)}}
  end

  @doc """
  Util to append a prefix to queue name, the idea is to use it internally to not conflict with reserved names
  """
  def queue_name(queue) do
    @prefix <> queue
  end

  defp my_queue_name do
    Registry.keys(Messaging.QueueRegistry, self()) |> List.first
  end

  defp get_interval() do
    Application.get_env(:core, :message_interval, 1000)
  end
end