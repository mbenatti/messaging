defmodule Messaging.CoreTest do
  use ExUnit.Case

  alias Messaging.Core.{Queue, QueueManager}

  # 10 milliseconds more because the cost of :process logic/process allocation
  @timeout 1010

  test "enqueue with different's queues" do
    queue1 = "queue1"
    queue2 = "queue2"

    QueueManager.enqueue(queue1, "My msg")
    QueueManager.enqueue(queue2, "My msg")

    assert [{pid, _}] = Registry.lookup(Messaging.QueuesRegistry, Queue.queue_name(queue1))
    assert [{pid2, _}] = Registry.lookup(Messaging.QueuesRegistry, Queue.queue_name(queue2))

    refute pid == pid2
  end

  test "ensure :process executed on each second" do
    queue = "my_queue"
    queue_name = Queue.queue_name(queue)

    QueueManager.start_queue(queue_name)

    [{pid, _}] = Registry.lookup(Messaging.QueuesRegistry, queue_name)

    :erlang.trace(pid, true, [:receive])

    QueueManager.enqueue(queue, "My msg2")
    QueueManager.enqueue(queue, "My msg3")
    QueueManager.enqueue(queue, "My msg4")

    # Receive/process each message in interval of @timeout
    assert_receive {:trace, ^pid, :receive, :process}, @timeout
    assert_receive {:trace, ^pid, :receive, :process}, @timeout
    assert_receive {:trace, ^pid, :receive, :process}, @timeout
  end

  test ":process successful processed the message" do
    queue = "my_queue"
    queue_name = Queue.queue_name(queue)

    QueueManager.start_queue(queue_name)

    [{pid, _}] = Registry.lookup(Messaging.QueuesRegistry, queue_name)

    :erlang.trace(pid, true, [:receive])

    QueueManager.enqueue(queue, "My msg2")
    QueueManager.enqueue(queue, "My msg3")
    QueueManager.enqueue(queue, "My msg4")

    # Receive callback of each message in interval
    assert_receive {:trace, ^pid, :receive, {_message_job_pid, :success}}, @timeout
    assert_receive {:trace, ^pid, :receive, {_message_job_pid, :success}}, @timeout
    assert_receive {:trace, ^pid, :receive, {_message_job_pid, :success}}, @timeout
  end
end
