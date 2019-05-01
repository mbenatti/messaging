defmodule Messaging.CoreTest do
  use ExUnit.Case

  alias Messaging.Core.{QueueManager, Queue}

  # 10 milliseconds more because the cost of :process_message logic
  @timeout 1010

  test "enqueue with different's queues" do
    queue1 = "queue1"
    queue2 = "queue2"

    QueueManager.enqueue(queue1, "My msg")
    QueueManager.enqueue(queue2, "My msg")

    assert [{pid, _}] = Registry.lookup(Messaging.QueueRegistry, Queue.queue_name(queue1))
    assert [{pid2, _}] = Registry.lookup(Messaging.QueueRegistry, Queue.queue_name(queue2))

    refute pid == pid2
  end

  test "ensure :process_message executed on each second" do
    queue_name = "queue_name"
    QueueManager.start_queue(queue_name)

    [{pid, _}] = Registry.lookup(Messaging.QueueRegistry, Queue.queue_name(queue_name))

    :erlang.trace(pid, true, [:receive])

    QueueManager.enqueue(queue_name, "My msg2")
    QueueManager.enqueue(queue_name, "My msg3")
    QueueManager.enqueue(queue_name, "My msg4")

    # Receive each message in interval of @timeout
    assert_receive {:trace, ^pid, :receive, :process_message}, @timeout
    assert_receive {:trace, ^pid, :receive, :process_message}, @timeout
    assert_receive {:trace, ^pid, :receive, :process_message}, @timeout
  end

  test ":process_message successful processed the message" do
    queue_name = "queue_name"
    QueueManager.start_queue(queue_name)

    [{pid, _}] = Registry.lookup(Messaging.QueueRegistry, Queue.queue_name(queue_name))

    :erlang.trace(pid, true, [:receive])

    QueueManager.enqueue(queue_name, "My msg2")
    QueueManager.enqueue(queue_name, "My msg3")
    QueueManager.enqueue(queue_name, "My msg4")

    # Receive each message in interval
    assert_receive {:trace, ^pid, :receive, {_ref, {:ok, _message_job_pid}}}, @timeout
    assert_receive {:trace, ^pid, :receive, {_ref, {:ok, _message_job_pid}}}, @timeout
    assert_receive {:trace, ^pid, :receive, {_ref, {:ok, _message_job_pid}}}, @timeout
  end
end
